<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<jsp:useBean id="billing" class="billing.billingBean" />
<%
Integer uid = (Integer) session.getAttribute("userId");
if (uid == null) { response.sendRedirect(request.getContextPath() + "/index.jsp"); return; }

String fromDate = request.getParameter("fromDate");
String toDate   = request.getParameter("toDate");
if (fromDate == null || fromDate.isEmpty() || toDate == null || toDate.isEmpty()) {
    response.sendRedirect(request.getContextPath() + "/reports/dayBook/page.jsp");
    return;
}

double cashOpening = billing.getDayBookCashOpeningBalance(fromDate);
double bankOpening = billing.getDayBookBankOpeningBalance(fromDate);
Vector cashBookRows = billing.getDayBookCashBook(fromDate, toDate);
Vector dayBookRows  = billing.getDayBookDetail(fromDate, toDate);
Vector salesRows    = billing.getDayBookSalesDetails(fromDate, toDate);

String[] descOrder = {"Opening Balance", "Bank Opening Balance", "Sales", "Balance Collection", "Purchase", "Supplier Payment", "Expense"};

LinkedHashMap<String, double[]> cashByDesc = new LinkedHashMap<>();
for (int o = 0; o < descOrder.length; o++) cashByDesc.put(descOrder[o], new double[]{0, 0});
for (int i = 0; i < cashBookRows.size(); i++) {
    Vector row = (Vector) cashBookRows.get(i);
    String category = row.get(2).toString();
    double cashIn  = (Double) row.get(4);
    double cashOut = (Double) row.get(5);
    if (!cashByDesc.containsKey(category)) cashByDesc.put(category, new double[]{0, 0});
    double[] t = cashByDesc.get(category);
    t[0] += cashIn;
    t[1] += cashOut;
}
LinkedHashMap<String, double[]> cashGroups = new LinkedHashMap<>();
for (Iterator cit = cashByDesc.entrySet().iterator(); cit.hasNext();) {
    Map.Entry ce = (Map.Entry) cit.next();
    double[] t = (double[]) ce.getValue();
    if (t[0] != 0 || t[1] != 0) cashGroups.put((String) ce.getKey(), t);
}

LinkedHashMap<String, double[]> dayByDesc = new LinkedHashMap<>();
for (int o = 0; o < descOrder.length; o++) dayByDesc.put(descOrder[o], new double[]{0, 0, 0, 0});
for (int i = 0; i < dayBookRows.size(); i++) {
    Vector row = (Vector) dayBookRows.get(i);
    String category = row.get(2).toString();
    double cashAmt   = (Double) row.get(4);
    double creditAmt = (Double) row.get(5);
    double bankAmt   = (Double) row.get(6);
    double totalAmt  = (Double) row.get(7);
    if (!dayByDesc.containsKey(category)) dayByDesc.put(category, new double[]{0, 0, 0, 0});
    double[] t = dayByDesc.get(category);
    t[0] += cashAmt;
    t[1] += creditAmt;
    t[2] += bankAmt;
    t[3] += totalAmt;
}
LinkedHashMap<String, double[]> dayGroups = new LinkedHashMap<>();
for (Iterator dit = dayByDesc.entrySet().iterator(); dit.hasNext();) {
    Map.Entry de = (Map.Entry) dit.next();
    double[] t = (double[]) de.getValue();
    if (t[0] != 0 || t[1] != 0 || t[2] != 0 || t[3] != 0) dayGroups.put((String) de.getKey(), t);
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Day Book Report</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
    <style>
        .section-title {
            font-size: 15px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: .4px;
            margin: 24px 0 10px;
            padding: 8px 12px;
            border-left: 4px solid var(--navy, #1e3a5f);
            background: var(--bill-bg, #f1f5f9);
        }
        .badge-cat { border-radius: 5px; padding: 2px 7px; font-size: 10px; font-weight: 700; white-space: nowrap; }
        .cat-Sales              { background:#dcfce7; color:#166534; }
        .cat-Balance-Collection { background:#dbeafe; color:#1e40af; }
        .cat-Purchase           { background:#ffedd5; color:#9a3412; }
        .cat-Supplier-Payment   { background:#f3e8ff; color:#6b21a8; }
        .cat-Expense            { background:#fef9c3; color:#854d0e; }
        .cat-Opening-Balance    { background:#e0f2fe; color:#0369a1; }
        .cat-Bank-Opening-Balance { background:#dbeafe; color:#1e40af; }
        .amt-in  { color:#166534; font-weight:600; }
        .amt-out { color:#991b1b; font-weight:600; }
        .bal-pos { color:#166534; font-weight:700; }
        .bal-neg { color:#991b1b; font-weight:700; }
        .status-cancelled { color:#991b1b; font-weight:700; }
        .status-active    { color:#166534; }
        .opening-row, .closing-row { background:#e0f2fe !important; font-weight:700; }
        @media print {
            @page { margin: 0.4cm; size: landscape; }
            .no-print { display: none !important; }
            body * { visibility: hidden; }
            #printArea, #printArea * { visibility: visible; }
            #printArea { position: absolute; left: 0; top: 0; width: 100%; }
            .section-title { break-after: avoid; }
        }
    </style>
</head>
<body>
<%@ include file="/assets/navbar/navbar.jsp" %>
<%
    request.setAttribute("pageTitle",    "Day Book");
    request.setAttribute("pageSubtitle", "Account Reports — " + fromDate + " to " + toDate);
    request.setAttribute("pageIcon",     "fa-solid fa-book-open");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

<div class="container-fluid mt-3 mst-page">
    <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2 no-print">
        <p class="mb-0 text-muted"><strong>Day Book:</strong> <%=fromDate%> &mdash; <%=toDate%></p>
        <div class="d-flex gap-2 flex-wrap">
            <a href="<%=contextPath%>/reports/dayBook/page.jsp" class="bb bb-outline">
                <i class="fa-solid fa-arrow-left me-1"></i>Back
            </a>
            <button class="bb bb-navy" onclick="printReport()">
                <i class="fa-solid fa-print me-1"></i>Print
            </button>
            <button class="bb bb-green" onclick="exportAllExcel()">
                <i class="fa-solid fa-file-excel me-1"></i>Excel
            </button>
            <button class="bb bb-outline" onclick="downloadPdf()">
                <i class="fa-solid fa-file-pdf me-1"></i>PDF
            </button>
            <button class="bb bb-outline" data-bs-toggle="modal" data-bs-target="#openingBalanceModal" title="Add Opening Balance">
                <i class="fa-solid fa-wallet me-1"></i>Opening Balance
            </button>
        </div>
    </div>

    <div id="printArea">

        <!-- ========== SECTION 1: CASH BOOK ========== -->
        <div class="section-title">1. Cash Book</div>
        <div class="table-responsive">
        <table id="cashBookTable" class="table mst-table table-sm">
            <thead>
                <tr>
                    <th>#</th>
                    <th>Description</th>
                    <th class="text-end">Cash In</th>
                    <th class="text-end">Cash Out</th>
                    <th class="text-end">Balance</th>
                </tr>
            </thead>
            <tbody>
<%
double cashBal = cashOpening;
double totCashIn = 0, totCashOut = 0;
int sno = 0;
%>
                <tr class="opening-row">
                    <td></td>
                    <td><strong>Opening Balance (B/F)</strong></td>
                    <td class="text-end"></td>
                    <td class="text-end"></td>
                    <td class="text-end <%=cashBal >= 0 ? "bal-pos" : "bal-neg"%>"><%=String.format("%.2f", cashBal)%></td>
                </tr>
<%
for (Iterator git = cashGroups.entrySet().iterator(); git.hasNext();) {
    Map.Entry ge = (Map.Entry) git.next();
    String category = (String) ge.getKey();
    double[] t = (double[]) ge.getValue();
    double cashIn  = t[0];
    double cashOut = t[1];
    cashBal += cashIn - cashOut;
    totCashIn  += cashIn;
    totCashOut += cashOut;
    sno++;
    String catKey = category.replace(" ", "-");
%>
                <tr>
                    <td><%=sno%></td>
                    <td><span class="badge-cat cat-<%=catKey%>"><%=category%></span></td>
                    <td class="text-end amt-in"><%=cashIn > 0 ? String.format("%.2f", cashIn) : ""%></td>
                    <td class="text-end amt-out"><%=cashOut > 0 ? String.format("%.2f", cashOut) : ""%></td>
                    <td class="text-end <%=cashBal >= 0 ? "bal-pos" : "bal-neg"%>"><%=String.format("%.2f", cashBal)%></td>
                </tr>
<% } %>
                <tr class="closing-row">
                    <td></td>
                    <td><strong>Closing Balance</strong></td>
                    <td class="text-end amt-in"><strong><%=String.format("%.2f", totCashIn)%></strong></td>
                    <td class="text-end amt-out"><strong><%=String.format("%.2f", totCashOut)%></strong></td>
                    <td class="text-end <%=cashBal >= 0 ? "bal-pos" : "bal-neg"%>"><strong><%=String.format("%.2f", cashBal)%></strong></td>
                </tr>
            </tbody>
        </table>
        </div>

        <!-- ========== SECTION 2: DAY BOOK ========== -->
        <div class="section-title">2. Day Book</div>
        <div class="table-responsive">
        <table id="dayBookTable" class="table mst-table table-sm">
            <thead>
                <tr>
                    <th>#</th>
                    <th>Description</th>
                    <th class="text-end">Cash</th>
                    <th class="text-end">Credit</th>
                    <th class="text-end">Bank</th>
                    <th class="text-end">Total</th>
                </tr>
            </thead>
            <tbody>
<%
double dayBookBankOpening = bankOpening;
double sumCash = 0, sumCredit = 0, sumBank = 0, sumTotal = 0;
sno = 0;
%>
                <tr class="opening-row">
                    <td></td>
                    <td><strong>Bank Opening Balance (B/F)</strong></td>
                    <td class="text-end"></td>
                    <td class="text-end"></td>
                    <td class="text-end <%=dayBookBankOpening >= 0 ? "bal-pos" : "bal-neg"%>"><%=String.format("%.2f", dayBookBankOpening)%></td>
                    <td class="text-end <%=dayBookBankOpening >= 0 ? "bal-pos" : "bal-neg"%>"><%=String.format("%.2f", dayBookBankOpening)%></td>
                </tr>
<%
for (Iterator dgit = dayGroups.entrySet().iterator(); dgit.hasNext();) {
    Map.Entry dge = (Map.Entry) dgit.next();
    String category = (String) dge.getKey();
    double[] t = (double[]) dge.getValue();
    double cashAmt   = t[0];
    double creditAmt = t[1];
    double bankAmt   = t[2];
    double totalAmt  = t[3];
    sumCash   += cashAmt;
    sumCredit += creditAmt;
    sumBank   += bankAmt;
    sumTotal  += totalAmt;
    sno++;
    String catKey = category.replace(" ", "-");
%>
                <tr>
                    <td><%=sno%></td>
                    <td><span class="badge-cat cat-<%=catKey%>"><%=category%></span></td>
                    <td class="text-end"><%=cashAmt != 0 ? String.format("%.2f", cashAmt) : ""%></td>
                    <td class="text-end"><%=creditAmt != 0 ? String.format("%.2f", creditAmt) : ""%></td>
                    <td class="text-end"><%=bankAmt != 0 ? String.format("%.2f", bankAmt) : ""%></td>
                    <td class="text-end fw-bold"><%=String.format("%.2f", totalAmt)%></td>
                </tr>
<% } %>
            </tbody>
            <tfoot>
                <tr style="background:var(--bill-bg);font-weight:700;">
                    <th colspan="2" class="text-end">Grand Total</th>
                    <th class="text-end"><%=String.format("%.2f", sumCash)%></th>
                    <th class="text-end"><%=String.format("%.2f", sumCredit)%></th>
                    <th class="text-end"><%=String.format("%.2f", sumBank)%></th>
                    <th class="text-end"><%=String.format("%.2f", sumTotal)%></th>
                </tr>
            </tfoot>
        </table>
        </div>

        <!-- ========== SECTION 3: SALES DETAILS ========== -->
        <div class="section-title">3. Sales Amount Details</div>
        <div class="table-responsive">
        <table id="salesDetailTable" class="table mst-table table-sm">
            <thead>
                <tr>
                    <th>#</th>
                    <th>Date</th>
                    <th>Bill No</th>
                    <th>Status</th>
                    <th>Sale Type</th>
                    <th>Customer Name</th>
                    <th class="text-end">Amount</th>
                </tr>
            </thead>
            <tbody>
<%
double salesTotal = 0;
sno = 0;
for (int i = 0; i < salesRows.size(); i++) {
    Vector row = (Vector) salesRows.get(i);
    String billDate = row.get(0).toString();
    String billNo   = row.get(1).toString();
    String status   = row.get(2).toString();
    String saleType = row.get(3).toString();
    String custName = row.get(4).toString();
    double amount   = (Double) row.get(5);
    if (!"Cancelled".equals(status)) salesTotal += amount;
    sno++;
    String statusClass = "Cancelled".equals(status) ? "status-cancelled" : "status-active";
%>
                <tr>
                    <td><%=sno%></td>
                    <td><%=billDate%></td>
                    <td><%=billNo%></td>
                    <td class="<%=statusClass%>"><%=status%></td>
                    <td><%=saleType%></td>
                    <td><%=custName%></td>
                    <td class="text-end"><%=String.format("%.2f", amount)%></td>
                </tr>
<% } %>
            </tbody>
            <tfoot>
                <tr style="background:var(--bill-bg);font-weight:700;">
                    <th colspan="6" class="text-end">Active Sales Total</th>
                    <th class="text-end"><%=String.format("%.2f", salesTotal)%></th>
                </tr>
            </tfoot>
        </table>
        </div>

    </div><!-- /printArea -->
</div>

<script>
function printReport() {
    var printArea = document.createElement('div');
    printArea.id = 'printAreaTemp';
    fetch('<%=contextPath%>/printHeader.jsp')
        .then(function(r) { return r.text(); })
        .then(function(headerHtml) {
            printArea.innerHTML = headerHtml;
            var title = document.createElement('h4');
            title.style.textAlign = 'center';
            title.textContent = 'Day Book Report — <%=fromDate%> to <%=toDate%>';
            printArea.appendChild(title);
            var clone = document.getElementById('printArea').cloneNode(true);
            printArea.appendChild(clone);
            document.body.appendChild(printArea);
            var style = document.createElement('style');
            style.textContent = '@media print { body * { visibility:hidden; } #printAreaTemp, #printAreaTemp * { visibility:visible; } #printAreaTemp { position:absolute; left:0; top:0; width:100%; } }';
            document.head.appendChild(style);
            window.print();
            document.body.removeChild(printArea);
            document.head.removeChild(style);
        })
        .catch(function() { window.print(); });
}

function exportAllExcel() {
    var tables = ['cashBookTable', 'dayBookTable', 'salesDetailTable'];
    var titles = ['Cash Book', 'Day Book', 'Sales Amount Details'];
    var html = '<html xmlns:x="urn:schemas-microsoft-com:office:excel"><head><meta charset="UTF-8">';
    html += '<style>table{border-collapse:collapse;margin-bottom:20px} th,td{border:1px solid #000;padding:4px;font-size:12px} h3{margin-top:16px}</style></head><body>';
    html += '<h2>Day Book Report — <%=fromDate%> to <%=toDate%></h2>';
    for (var i = 0; i < tables.length; i++) {
        var tbl = document.getElementById(tables[i]);
        if (tbl) {
            html += '<h3>' + titles[i] + '</h3>' + tbl.outerHTML;
        }
    }
    html += '</body></html>';
    var blob = new Blob(['\ufeff', html], { type: 'application/vnd.ms-excel' });
    var a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = 'Day_Book_<%=fromDate%>_<%=toDate%>.xls';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(a.href);
}

function downloadPdf() {
    var element = document.getElementById('printArea');
    if (typeof html2pdf === 'undefined') {
        alert('PDF library not loaded. Please use Print and choose Save as PDF.');
        return;
    }
    var opt = {
        margin:       8,
        filename:     'Day_Book_<%=fromDate%>_<%=toDate%>.pdf',
        image:        { type: 'jpeg', quality: 0.95 },
        html2canvas:  { scale: 2, useCORS: true },
        jsPDF:        { unit: 'mm', format: 'a4', orientation: 'landscape' },
        pagebreak:    { mode: ['avoid-all', 'css', 'legacy'] }
    };
    html2pdf().set(opt).from(element).save();
}

function updateObNotesPlaceholder() {
    const type = document.getElementById('obType').value;
    document.getElementById('obNotes').placeholder = type === 'bank'
        ? 'Bank opening balance'
        : 'Opening cash in hand';
}

function loadOpeningBalanceList() {
    fetch('<%=contextPath%>/reports/dayBook/getOpeningBalanceList.jsp')
        .then(r => r.json())
        .then(data => {
            const tbody = document.getElementById('obListBody');
            if (!data.length) {
                tbody.innerHTML = '<tr><td colspan="5" class="text-center text-muted">No opening balance entries yet.</td></tr>';
                return;
            }
            tbody.innerHTML = data.map(row =>
                '<tr><td>' + row.balanceDate + '</td>' +
                '<td><span class="badge bg-' + (row.balanceType === 'bank' ? 'primary' : 'success') + '">' +
                (row.balanceType === 'bank' ? 'Bank' : 'Cash') + '</span></td>' +
                '<td class="text-end fw-bold">' + parseFloat(row.amount).toFixed(2) + '</td>' +
                '<td>' + (row.notes || '-') + '</td>' +
                '<td>' + (row.userName || '-') + '</td></tr>'
            ).join('');
        })
        .catch(() => {
            document.getElementById('obListBody').innerHTML =
                '<tr><td colspan="5" class="text-center text-danger">Could not load list.</td></tr>';
        });
}

function saveOpeningBalance() {
    const balanceDate = document.getElementById('obDate').value;
    const balanceType = document.getElementById('obType').value;
    const amount = document.getElementById('obAmount').value;
    const notes = document.getElementById('obNotes').value;
    if (!balanceDate || !amount) {
        Swal.fire({ icon: 'warning', title: 'Required', text: 'Please enter date and amount.' });
        return;
    }
    fetch('<%=contextPath%>/reports/dayBook/saveOpeningBalance.jsp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({ balanceDate, balanceType, amount, notes }).toString()
    })
    .then(r => r.json())
    .then(res => {
        if (res.success) {
            Swal.fire({ icon: 'success', title: 'Saved', text: res.message, timer: 1800, showConfirmButton: false });
            document.getElementById('obAmount').value = '';
            document.getElementById('obNotes').value = '';
            loadOpeningBalanceList();
        } else {
            Swal.fire({ icon: 'error', title: 'Error', text: res.message });
        }
    });
}

document.getElementById('obType').addEventListener('change', updateObNotesPlaceholder);
document.getElementById('openingBalanceModal').addEventListener('show.bs.modal', function() {
    updateObNotesPlaceholder();
    loadOpeningBalanceList();
});
</script>

<!-- Opening Balance Modal -->
<div class="modal fade no-print" id="openingBalanceModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="fa-solid fa-wallet me-2"></i>Add Opening Balance</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="row g-3 mb-3">
                    <div class="col-md-3">
                        <label class="form-label fw-bold">Date</label>
                        <input type="date" id="obDate" class="form-control" value="<%=fromDate%>">
                    </div>
                    <div class="col-md-3">
                        <label class="form-label fw-bold">Type</label>
                        <select id="obType" class="form-select">
                            <option value="cash">Cash</option>
                            <option value="bank">Bank</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label fw-bold">Amount</label>
                        <input type="number" id="obAmount" class="form-control" step="0.01" placeholder="0.00">
                    </div>
                    <div class="col-md-3">
                        <label class="form-label fw-bold">Notes</label>
                        <input type="text" id="obNotes" class="form-control" placeholder="Opening balance notes">
                    </div>
                </div>
                <button type="button" class="bb bb-primary mb-3" onclick="saveOpeningBalance()">
                    <i class="fa-solid fa-floppy-disk me-1"></i>Save
                </button>
                <div class="table-responsive" style="max-height:260px;">
                    <table class="table table-sm mst-table">
                        <thead><tr><th>Date</th><th>Type</th><th class="text-end">Amount</th><th>Notes</th><th>User</th></tr></thead>
                        <tbody id="obListBody"><tr><td colspan="5" class="text-center text-muted">Loading...</td></tr></tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
