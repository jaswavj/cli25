<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<jsp:useBean id="bill" class="billing.billingBean" />
<%
String msg = request.getParameter("msg");
String type = request.getParameter("type");
boolean dueOnly = !"all".equals(request.getParameter("view"));

double totalBalance = 0;
int pendingCount = 0;
Vector supplierList = new Vector();
try {
    totalBalance = bill.getTotalSupplierOutstandingBalance();
    pendingCount = bill.getPendingSupplierCount();
    supplierList = bill.getAllSupplierWiseBalanceList(dueOnly);
} catch (Exception e) {
    if (msg == null) {
        msg = "Run database/prod_supplier_balance_setup.sql if balance column is missing.";
        type = "warning";
    }
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Supplier Payment</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        .summary-card { border:none; box-shadow:0 2px 8px rgba(0,0,0,.08); border-radius:10px; }
        .summary-value { font-size:1.6rem; font-weight:800; }
        .supplier-row { cursor:pointer; }
        .supplier-row:hover td { background:#f8fafc !important; }
        .supplier-row.zero-balance td { color:#64748b; }
    </style>
</head>
<body>
<%@ include file="/assets/navbar/navbar.jsp" %>
<%
    request.setAttribute("pageTitle",    "Supplier Payment");
    request.setAttribute("pageSubtitle", "Credit Collection — Supplier Balances");
    request.setAttribute("pageIcon",     "fa-solid fa-hand-holding-dollar");
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
    <div class="row g-3 mb-3">
        <div class="col-md-6">
            <div class="card summary-card">
                <div class="card-body">
                    <div class="text-muted small text-uppercase fw-bold">Total Supplier Balance</div>
                    <div class="summary-value text-danger">&#8377; <%= String.format("%,.2f", totalBalance) %></div>
                </div>
            </div>
        </div>
        <div class="col-md-6">
            <div class="card summary-card">
                <div class="card-body">
                    <div class="text-muted small text-uppercase fw-bold">Pending Suppliers</div>
                    <div class="summary-value" style="color:var(--bill-navy)"><%= pendingCount %></div>
                </div>
            </div>
        </div>
    </div>

    <div class="card mb-3" style="border:none; box-shadow:0 2px 4px rgba(0,0,0,.07); border-radius:8px;">
        <div class="card-body p-3">
            <h6 class="mb-3 fw-bold"><i class="fa-solid fa-magnifying-glass me-2"></i>Search Supplier</h6>
            <div style="position:relative;max-width:520px;">
                <input type="text" id="supplierSearch" class="form-control fg-inp" placeholder="Type supplier name or phone..." autocomplete="off">
                <ul id="supplierDropdown" style="display:none;position:absolute;top:100%;left:0;right:0;z-index:1000;background:#fff;border:1.5px solid #d1d9e6;border-top:none;border-radius:0 0 8px 8px;list-style:none;padding:0;margin:0;max-height:260px;overflow-y:auto;box-shadow:0 4px 16px rgba(0,0,0,.10);"></ul>
            </div>
            <div id="selectedSupplierBox" style="display:none;margin-top:14px;border:1.5px solid #22c55e;border-radius:8px;padding:12px 14px;background:#f0fdf4;">
                <div class="d-flex justify-content-between align-items-center gap-2 flex-wrap">
                    <div>
                        <div class="fw-bold" id="selSupName"></div>
                        <div class="text-muted small" id="selSupPhone"></div>
                    </div>
                    <button type="button" class="btn btn-sm btn-success" onclick="goToSupplierDetails()">
                        View Details <i class="fa-solid fa-arrow-right ms-1"></i>
                    </button>
                </div>
            </div>
        </div>
    </div>

    <div class="card" style="border:none; box-shadow:0 2px 4px rgba(0,0,0,.07); border-radius:8px;">
        <div class="mst-card-header-light py-2 px-3 d-flex justify-content-between align-items-center flex-wrap gap-2">
            <h6 class="mb-0"><i class="fas fa-truck me-2"></i>Supplier-wise Balance</h6>
            <div class="btn-group btn-group-sm">
                <a href="<%=contextPath%>/product/supplierPayment/page.jsp?view=due" class="btn <%= dueOnly ? "btn-primary" : "btn-outline-primary" %>">Due Only</a>
                <a href="<%=contextPath%>/product/supplierPayment/page.jsp?view=all" class="btn <%= !dueOnly ? "btn-primary" : "btn-outline-primary" %>">All Suppliers</a>
            </div>
        </div>
        <div class="table-responsive">
            <table class="table table-hover mb-0 mst-table" style="min-width:900px; width:100%;">
                <thead>
                    <tr>
                        <th style="width:50px;">#</th>
                        <th>Supplier</th>
                        <th style="width:140px;">Phone</th>
                        <th class="text-end" style="width:120px;">Pending Bills</th>
                        <th class="text-end" style="width:140px;">Bill Balance</th>
                        <th class="text-end" style="width:140px;">Total Balance</th>
                        <th class="text-center" style="width:130px;">Action</th>
                    </tr>
                </thead>
                <tbody>
                <% if (supplierList.isEmpty()) { %>
                    <tr><td colspan="7" class="text-center text-muted py-4"><%= dueOnly ? "No pending supplier balance." : "No suppliers found." %></td></tr>
                <% } else {
                    for (int i = 0; i < supplierList.size(); i++) {
                        Vector row = (Vector) supplierList.get(i);
                        int supId = Integer.parseInt(row.get(0).toString());
                        String supName = row.get(1).toString();
                        String phone = row.get(2).toString();
                        double supBalance = Double.parseDouble(row.get(3).toString());
                        int pendingBills = Integer.parseInt(row.get(4).toString());
                        double billBalance = Double.parseDouble(row.get(5).toString());
                        boolean hasDue = supBalance > 0;
                %>
                    <tr class="supplier-row <%= hasDue ? "" : "zero-balance" %>" onclick="location.href='<%=contextPath%>/product/supplierPayment/page1.jsp?supId=<%=supId%>'">
                        <td><%= i + 1 %></td>
                        <td class="fw-bold"><%= supName %></td>
                        <td><%= phone.isEmpty() ? "-" : phone %></td>
                        <td class="text-end"><%= pendingBills %></td>
                        <td class="text-end">&#8377; <%= String.format("%,.2f", billBalance) %></td>
                        <td class="text-end <%= hasDue ? "text-danger fw-bold" : "text-success" %>">&#8377; <%= String.format("%,.2f", supBalance) %></td>
                        <td class="text-center">
                            <a href="<%=contextPath%>/product/supplierPayment/page1.jsp?supId=<%=supId%>" class="bb bb-outline btn-sm" onclick="event.stopPropagation()">
                                View Details
                            </a>
                        </td>
                    </tr>
                <%  }
                   } %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
const contextPath = '<%=contextPath%>';
let selectedSupplierId = null;
let searchTimer = null;

const searchInput = document.getElementById('supplierSearch');
const dropdown = document.getElementById('supplierDropdown');

searchInput.addEventListener('input', function() {
    const val = this.value.trim();
    clearTimeout(searchTimer);
    dropdown.style.display = 'none';
    document.getElementById('selectedSupplierBox').style.display = 'none';
    selectedSupplierId = null;
    if (val.length < 1) return;

    searchTimer = setTimeout(() => {
        const isPhone = /^\d+$/.test(val);
        const params = isPhone ? 'phone=' + encodeURIComponent(val) : 'query=' + encodeURIComponent(val);
        fetch(contextPath + '/product/supplierPayment/supplierAutocomplete.jsp?' + params)
            .then(r => r.json())
            .then(data => renderDropdown(data))
            .catch(() => {});
    }, 280);
});

function renderDropdown(suppliers) {
    dropdown.innerHTML = '';
    if (!suppliers.length) {
        dropdown.innerHTML = '<li style="padding:10px 14px;color:#888;font-size:13px;">No suppliers found</li>';
        dropdown.style.display = 'block';
        return;
    }
    suppliers.forEach(s => {
        const li = document.createElement('li');
        li.style.cssText = 'padding:10px 14px;cursor:pointer;border-bottom:1px solid #f0f0f0;';
        li.innerHTML = '<span style="font-weight:600;">' + s.name + '</span>'
            + '<span style="font-size:12px;color:#888;margin-left:8px;">' + (s.phone !== '-' ? s.phone : '') + '</span>';
        li.addEventListener('mouseenter', () => li.style.background = '#f1f5f9');
        li.addEventListener('mouseleave', () => li.style.background = '');
        li.addEventListener('click', () => selectSupplier(s));
        dropdown.appendChild(li);
    });
    dropdown.style.display = 'block';
}

function selectSupplier(s) {
    selectedSupplierId = s.id;
    searchInput.value = s.name + (s.phone && s.phone !== '-' ? '  |  ' + s.phone : '');
    dropdown.style.display = 'none';
    document.getElementById('selSupName').textContent = s.name;
    document.getElementById('selSupPhone').textContent = s.phone && s.phone !== '-' ? s.phone : '';
    document.getElementById('selectedSupplierBox').style.display = 'block';
}

function goToSupplierDetails() {
    if (!selectedSupplierId) return;
    window.location.href = contextPath + '/product/supplierPayment/page1.jsp?supId=' + selectedSupplierId;
}

document.addEventListener('click', function(e) {
    if (!searchInput.contains(e.target) && !dropdown.contains(e.target)) {
        dropdown.style.display = 'none';
    }
});

searchInput.addEventListener('keydown', function(e) {
    if (e.key === 'Enter' && selectedSupplierId) goToSupplierDetails();
});
</script>
</body>
</html>
