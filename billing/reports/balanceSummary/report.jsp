<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<jsp:useBean id="billing" class="billing.billingBean" />
<%
Integer uid = (Integer) session.getAttribute("userId");
if (uid == null) { response.sendRedirect(request.getContextPath() + "/index.jsp"); return; }

String fromDate = request.getParameter("fromDate");
String toDate   = request.getParameter("toDate");
if (fromDate == null || fromDate.isEmpty() || toDate == null || toDate.isEmpty()) {
    response.sendRedirect(request.getContextPath() + "/reports/balanceSummary/page.jsp"); return;
}

double openingBalance = billing.getBalanceSummaryOpeningBalance(fromDate);
Vector vec = billing.getBalanceSummaryReport(fromDate, toDate);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Balance Summary Report</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        .badge-type { border-radius: 6px; padding: 2px 8px; font-size: 11px; font-weight: 700; }
        .badge-Sale            { background:#dcfce7; color:#166534; }
        .badge-Purchase        { background:#dbeafe; color:#1e40af; }
        .badge-Expense         { background:#fef9c3; color:#854d0e; }
        .badge-Cancel          { background:#fee2e2; color:#991b1b; }
        .badge-Purchase-Return { background:#f3e8ff; color:#6b21a8; }
        .amt-in  { color:#166534; font-weight:700; }
        .amt-out { color:#991b1b; font-weight:700; }
        .bal-pos { color:#166534; }
        .bal-neg { color:#991b1b; }
        @media print {
            @page { margin:0.4cm; size:landscape; }
            .no-print { display:none !important; }
            body * { visibility:hidden; }
            #printArea, #printArea * { visibility:visible; }
            #printArea { position:absolute; left:0; top:0; width:100%; }
        }
    </style>
</head>
<body>
<%@ include file="/assets/navbar/navbar.jsp" %>
<%
    request.setAttribute("pageTitle",    "Balance Summary");
    request.setAttribute("pageSubtitle", "Reports — Balance Summary");
    request.setAttribute("pageIcon",     "fa-solid fa-scale-balanced");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

<div class="container-fluid mt-3 mst-page">

    <!-- Toolbar -->
    <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
        <p class="mb-0 text-muted">
            <strong>Balance Summary:</strong> <%=fromDate%> &mdash; <%=toDate%>
        </p>
        <div class="d-flex gap-2 no-print">
            <a href="<%=contextPath%>/reports/balanceSummary/page.jsp" class="bb bb-outline">
                <i class="fa-solid fa-arrow-left me-1"></i>Back
            </a>
            <button class="bb bb-navy" onclick="window.print()">
                <i class="fa-solid fa-print me-1"></i>Print
            </button>
            <button class="bb bb-green" onclick="exportTableToExcel('balTable','Balance_Summary')">
                <i class="fa-solid fa-file-excel me-1"></i>Export
            </button>
        </div>
    </div>

    <!-- Opening Balance Card -->
    <div class="row g-3 mb-3 no-print">
        <div class="col-auto">
            <div class="p-3 rounded" style="background:#e0f2fe; border-left:4px solid #0284c7;">
                <div style="font-size:11px;color:#0369a1;font-weight:700;text-transform:uppercase;">Opening Balance (before <%=fromDate%>)</div>
                <div style="font-size:22px;font-weight:800;color:#0c4a6e;">
                    <%=String.format("%.2f", openingBalance)%>
                </div>
            </div>
        </div>
    </div>

    <div id="printArea">
    <div class="table-responsive">
    <table id="balTable" class="table mst-table mt-2">
        <thead>
            <tr>
                <th>#</th>
                <th>Date</th>
                <th>Content</th>
                <th class="text-end">In (+)</th>
                <th class="text-end">Out (-)</th>
                <th class="text-end">Closing Balance</th>
                <th>User</th>
                <th>Type</th>
            </tr>
        </thead>
        <tbody>
<%
double balance  = openingBalance;
double totalIn  = 0, totalOut = 0;
int sno = 0;

for (int i = 0; i < vec.size(); i++) {
    Vector row   = (Vector) vec.get(i);
    String txnDate  = row.get(0).toString();
    String content  = row.get(1).toString();
    double inAmt    = (Double) row.get(2);
    double outAmt   = (Double) row.get(3);
    String userName = row.get(4).toString();
    String type     = row.get(5).toString();

    balance  += inAmt - outAmt;
    totalIn  += inAmt;
    totalOut += outAmt;
    sno++;

    String badgeKey = type.replace(" ", "-");
    String balClass = balance >= 0 ? "bal-pos" : "bal-neg";
%>
            <tr>
                <td><%=sno%></td>
                <td><%=txnDate%></td>
                <td><%=content%></td>
                <td class="text-end amt-in">
                    <%=inAmt > 0 ? String.format("%.2f", inAmt) : ""%>
                </td>
                <td class="text-end amt-out">
                    <%=outAmt > 0 ? String.format("%.2f", outAmt) : ""%>
                </td>
                <td class="text-end fw-bold <%=balClass%>">
                    <%=String.format("%.2f", balance)%>
                </td>
                <td><%=userName%></td>
                <td><span class="badge-type badge-<%=badgeKey%>"><%=type%></span></td>
            </tr>
<% } %>
        </tbody>
        <tfoot>
            <tr>
                <th colspan="3" class="text-end">Totals</th>
                <th class="text-end amt-in"><%=String.format("%.2f", totalIn)%></th>
                <th class="text-end amt-out"><%=String.format("%.2f", totalOut)%></th>
                <th class="text-end <%=balance >= 0 ? "bal-pos" : "bal-neg"%>">
                    <%=String.format("%.2f", balance)%>
                </th>
                <th colspan="2"></th>
            </tr>
        </tfoot>
    </table>
    </div>
    </div><!-- /printArea -->

</div>
</body>
</html>
