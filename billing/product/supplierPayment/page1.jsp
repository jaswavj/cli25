<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ page import="java.util.*, javax.servlet.http.*" %>

<jsp:useBean id="bill" class="billing.billingBean" />

<jsp:useBean id="prod" class="product.productBean" />

<%

String supIdParam = request.getParameter("supId");

if (supIdParam == null || supIdParam.trim().isEmpty()) {

    response.sendRedirect(request.getContextPath() + "/product/supplierPayment/page.jsp");

    return;

}

int supId = Integer.parseInt(supIdParam);

Vector supplierInfo = prod.getSupplierDetail(supId);

if (supplierInfo == null || supplierInfo.isEmpty()) {

    response.sendRedirect(request.getContextPath() + "/product/supplierPayment/page.jsp?msg=Supplier+not+found&type=danger");

    return;

}



String supName = supplierInfo.get(1).toString();

double supBalance = Double.parseDouble(supplierInfo.get(4).toString());

int isGst = Integer.parseInt(supplierInfo.get(5).toString());



Vector billList = bill.getDueSupplierBills(supId);

Vector ledgerList = bill.getSupplierBalanceLedger(supId);

double billBalanceTotal = 0;

for (int i = 0; i < billList.size(); i++) {

    Vector row = (Vector) billList.get(i);

    billBalanceTotal += Double.parseDouble(row.get(5).toString());

}

double oldBalance = supBalance - billBalanceTotal;

if (oldBalance < 0) oldBalance = 0;



double[] ledgerRunningBalance = new double[ledgerList.size()];

double runningCalc = supBalance;

for (int li = 0; li < ledgerList.size(); li++) {

    Vector ledgerRow = (Vector) ledgerList.get(li);

    String ledgerType = ledgerRow.get(2).toString();

    double ledgerAmt = Double.parseDouble(ledgerRow.get(3).toString());

    ledgerRunningBalance[li] = runningCalc;

    if ("payment".equals(ledgerType)) {

        runningCalc += ledgerAmt;

    } else {

        runningCalc -= ledgerAmt;

    }

}



String msg = request.getParameter("msg");

String type = request.getParameter("type");

%>

<!DOCTYPE html>

<html lang="en">

<head>

    <meta charset="UTF-8">

    <title>Supplier Balance - <%= supName %></title>

    <meta name="viewport" content="width=device-width, initial-scale=1">

    <%@ include file="/assets/common/head.jsp" %>

    <style>
        .sup-info-label { font-size:0.78rem; font-weight:700; text-transform:uppercase; letter-spacing:.4px; color:#64748b; margin-bottom:4px; }
        .sup-info-value { font-size:1.15rem; font-weight:700; color:#1e293b; white-space:nowrap; }
        .sup-bal-card {
            border:none; border-radius:10px;
            box-shadow:0 3px 10px rgba(0,0,0,.1);
            background:linear-gradient(135deg, #fffbeb 0%, #fef3c7 100%);
            border:1px solid #fcd34d;
        }
        .sup-bal-card .sup-info-label { color:#92400e; }
        .sup-bal-card .sup-info-value {
            font-size:1.85rem; font-weight:800; line-height:1.2;
            color:#b45309; white-space:nowrap;
        }
        .sup-bal-total {
            background:linear-gradient(135deg, #fff1f2 0%, #fecdd3 100%);
            border:2px solid #f87171;
            box-shadow:0 4px 14px rgba(220,38,38,.18);
        }
        .sup-bal-total .sup-info-label { color:#be123c; font-size:0.82rem; }
        .sup-bal-total .sup-info-value {
            font-size:2rem; font-weight:900;
            color:#dc2626; white-space:nowrap;
        }
    </style>

</head>

<body>

<%@ include file="/assets/navbar/navbar.jsp" %>

<%

    request.setAttribute("pageTitle",    supName);

    request.setAttribute("pageSubtitle", "Supplier Balance & Collection");

    request.setAttribute("pageIcon",     "fa-solid fa-truck-ramp-box");

%>

<jsp:include page="/assets/common/pageHeader.jsp" />



<% if (msg != null) { %>

<div class="container-fluid mt-2">

    <div class="alert alert-<%= (type != null ? type : "info") %> alert-dismissible fade show" role="alert">

        <%= msg %>

        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>

    </div>

</div>

<% } %>



<div class="container-fluid mt-2 mst-page">

    <div class="d-flex gap-2 mb-3 flex-wrap">

        <a href="<%=contextPath%>/product/supplierPayment/page.jsp" class="bb bb-outline">

            <i class="fa-solid fa-arrow-left me-1"></i>Back

        </a>

        <button type="button" class="bb bb-primary" data-bs-toggle="modal" data-bs-target="#addOldBalanceModal">

            <i class="fa-solid fa-plus me-1"></i>Add Old Balance

        </button>

    </div>



    <div class="row g-3 mb-3">

        <div class="col-md-4">

            <div class="card sup-bal-card"><div class="card-body py-3">

                <div class="sup-info-label">Old Balance</div>

                <div class="sup-info-value">&#8377; <%= String.format("%,.2f", oldBalance) %></div>

            </div></div>

        </div>

        <div class="col-md-4">

            <div class="card sup-bal-card"><div class="card-body py-3">

                <div class="sup-info-label">Bill Balance</div>

                <div class="sup-info-value">&#8377; <%= String.format("%,.2f", billBalanceTotal) %></div>

            </div></div>

        </div>

        <div class="col-md-4">

            <div class="card sup-bal-card sup-bal-total"><div class="card-body py-3">

                <div class="sup-info-label">Total Balance</div>

                <div class="sup-info-value">&#8377; <%= String.format("%,.2f", supBalance) %></div>

            </div></div>

        </div>

    </div>



    <% if (supBalance > 0) { %>

    <div class="card mb-3" style="border:none; box-shadow:0 2px 4px rgba(0,0,0,.07); border-radius:8px;">

        <div class="mst-card-header py-2 px-3">

            <h6 class="mb-0"><i class="fas fa-money-bill-wave me-2"></i>Collect Payment (Total Balance)</h6>

        </div>

        <div class="card-body">

            <form action="<%=contextPath%>/product/supplierPayment/saveSupplierTotalPayment.jsp" method="post" class="row g-3 align-items-end">

                <input type="hidden" name="supId" value="<%=supId%>">

                <div class="col-md-3">

                    <label class="form-label fw-bold">Amount to Collect</label>

                    <input type="number" name="amount" id="payAmount" class="form-control" step="0.01" min="0.01"

                           max="<%= String.format("%.2f", supBalance) %>" placeholder="0.00" required>

                    <small class="text-muted">Max: &#8377;<%= String.format("%,.2f", supBalance) %></small>

                </div>

                <div class="col-md-2">

                    <label class="form-label fw-bold">Payment Mode</label>

                    <select class="form-select" id="mode" name="mode">

                        <option value="1" <%= isGst != 1 ? "selected" : "" %>>Cash</option>

                        <option value="2" <%= isGst == 1 ? "selected" : "" %>>Bank</option>

                    </select>

                </div>

                <div class="col-md-3">

                    <label class="form-label fw-bold">Bank Option</label>

                    <select class="form-select" id="bankOption" name="bankOption" <%= isGst != 1 ? "disabled" : "" %>>

                        <option value="0">--Select--</option>

                        <%

                            Vector paymentTypes = prod.getBillPaymentTypes();

                            for (int i = 0; i < paymentTypes.size(); i++) {

                                Vector payType = (Vector) paymentTypes.get(i);

                                int id = Integer.parseInt(payType.get(0).toString());

                                if (id != 0) {

                        %>

                        <option value="<%= id %>"><%= payType.get(1).toString() %></option>

                        <%      }

                            }

                        %>

                    </select>

                </div>

                <div class="col-md-2">

                    <button type="submit" class="bb bb-primary w-100">

                        <i class="fa-solid fa-hand-holding-dollar me-1"></i>Collect

                    </button>

                </div>

            </form>

        </div>

    </div>

    <% } %>



    <div class="card mb-3" style="border:none; box-shadow:0 2px 4px rgba(0,0,0,.07); border-radius:8px;">

        <div class="mst-card-header-light py-2 px-3">

            <h6 class="mb-0"><i class="fas fa-list me-2"></i>Balance History</h6>

        </div>

        <div class="table-responsive">

            <table class="table mst-table mb-0" style="min-width:900px; width:100%;">

                <thead>

                    <tr>

                        <th>Date</th>

                        <th>Time</th>

                        <th>Type</th>

                        <th>Description</th>

                        <th class="text-end">Credit (+)</th>

                        <th class="text-end">Debit (-)</th>

                        <th class="text-end">Running Balance</th>

                        <th>User</th>

                    </tr>

                </thead>

                <tbody>

                <% if (ledgerList.isEmpty()) { %>

                    <tr><td colspan="8" class="text-center text-muted py-3">No balance history yet.</td></tr>

                <% } else {

                    for (int i = 0; i < ledgerList.size(); i++) {

                        Vector row = (Vector) ledgerList.get(i);

                        String entryType = row.get(2).toString();

                        double amt = Double.parseDouble(row.get(3).toString());

                        String typeLabel = entryType;

                        if ("opening".equals(entryType)) typeLabel = "Old Balance";

                        else if ("purchase".equals(entryType)) typeLabel = "Purchase Credit";

                        else if ("payment".equals(entryType)) typeLabel = "Payment";

                        boolean isPayment = "payment".equals(entryType);

                %>

                    <tr>

                        <td><%= row.get(0) %></td>

                        <td><%= row.get(1) %></td>

                        <td><span class="badge bg-<%= isPayment ? "success" : "warning text-dark" %>"><%= typeLabel %></span></td>

                        <td><%= row.get(4) %></td>

                        <td class="text-end"><%= isPayment ? "" : String.format("%,.2f", amt) %></td>

                        <td class="text-end text-success fw-bold"><%= isPayment ? String.format("%,.2f", amt) : "" %></td>

                        <td class="text-end text-danger fw-bold">&#8377; <%= String.format("%,.2f", ledgerRunningBalance[i]) %></td>

                        <td><%= row.get(5) %></td>

                    </tr>

                <%  }

                   } %>

                </tbody>

            </table>

        </div>

    </div>



    <div class="card" style="border:none; box-shadow:0 2px 4px rgba(0,0,0,.07); border-radius:8px;">

        <div class="mst-card-header-light py-2 px-3">

            <h6 class="mb-0"><i class="fas fa-file-invoice-dollar me-2"></i>Pending Purchase Bills</h6>

        </div>

        <div class="table-responsive">

            <table class="table mst-table mb-0">

                <thead>

                    <tr>

                        <th>S.No</th>

                        <th>Inv/GR No</th>

                        <th>Invoice Date</th>

                        <th class="text-end">Total</th>

                        <th class="text-end">Paid</th>

                        <th class="text-end">Balance</th>

                        <th>Date/Time</th>

                        <th>User</th>

                    </tr>

                </thead>

                <tbody>

                <% if (billList.isEmpty()) { %>

                    <tr><td colspan="8" class="text-center text-muted py-3">No pending purchase bills.</td></tr>

                <% } else {

                    for (int i = 0; i < billList.size(); i++) {

                        Vector row = (Vector) billList.get(i);

                        int billId = Integer.parseInt(row.get(0).toString());

                %>

                    <tr>

                        <td><%= i + 1 %></td>

                        <td><a href="<%=contextPath%>/product/purchase/report/purchaseRegister/purchaseDetails.jsp?id=<%=billId%>"><%= row.get(1) %>/<%= row.get(9) %></a></td>

                        <td><%= row.get(2) %></td>

                        <td class="text-end"><%= row.get(3) %></td>

                        <td class="text-end"><%= row.get(4) %></td>

                        <td class="text-end text-danger fw-bold"><%= row.get(5) %></td>

                        <td><%= row.get(6) %></td>

                        <td><%= row.get(7) %></td>

                    </tr>

                <%  }

                   } %>

                </tbody>

            </table>

        </div>

    </div>

</div>



<div class="modal fade" id="addOldBalanceModal" tabindex="-1" aria-hidden="true">

    <div class="modal-dialog">

        <div class="modal-content">

            <form action="<%=contextPath%>/product/supplierPayment/saveSupplierOpeningBalance.jsp" method="post">

                <input type="hidden" name="supId" value="<%=supId%>">

                <div class="modal-header">

                    <h5 class="modal-title">Add Old Balance — <%= supName %></h5>

                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>

                </div>

                <div class="modal-body">

                    <div class="mb-3">

                        <label class="form-label fw-bold">Amount</label>

                        <input type="number" name="amount" class="form-control" step="0.01" min="0.01" required placeholder="0.00">

                    </div>

                    <div class="mb-3">

                        <label class="form-label fw-bold">Notes <span class="text-muted fw-normal">(optional)</span></label>

                        <input type="text" name="notes" class="form-control" placeholder="Old balance before system">

                    </div>

                </div>

                <div class="modal-footer">

                    <button type="button" class="bb bb-outline" data-bs-dismiss="modal">Cancel</button>

                    <button type="submit" class="bb bb-primary">Save Old Balance</button>

                </div>

            </form>

        </div>

    </div>

</div>



<script>

const modeSelect = document.getElementById('mode');

const bankOption = document.getElementById('bankOption');

const payAmount = document.getElementById('payAmount');

const maxBalance = <%= supBalance %>;



if (modeSelect && bankOption) {

    modeSelect.addEventListener('change', function() {

        if (this.value === '2') {

            bankOption.removeAttribute('disabled');

        } else {

            bankOption.value = '0';

            bankOption.setAttribute('disabled', 'disabled');

        }

    });

}



if (payAmount) {

    payAmount.addEventListener('input', function() {

        const val = parseFloat(this.value) || 0;

        if (val > maxBalance) {

            Swal.fire({ icon: 'warning', title: 'Limit exceeded', text: 'Amount cannot exceed total balance.' });

            this.value = maxBalance.toFixed(2);

        }

    });

}



const payForm = document.querySelector('form[action*="saveSupplierTotalPayment"]');

if (payForm && bankOption) {

    payForm.addEventListener('submit', function() {

        if (bankOption.disabled) {

            bankOption.disabled = false;

            bankOption.value = '0';

        }

    });

}

</script>

</body>

</html>

