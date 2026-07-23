<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<%@ page import="java.text.SimpleDateFormat, java.util.Date" %>
<%
String today = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Profit Analysis Report</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>
    <jsp:include page="/assets/navbar/navbar.jsp" />
<%
    request.setAttribute("pageTitle",    "Profit Analysis");
    request.setAttribute("pageSubtitle", "Total Sales − Total Purchase − Total Expense");
    request.setAttribute("pageIcon",     "fa-solid fa-chart-line");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

<div class="container-fluid mt-3 mst-page">

    <form action="<%=contextPath%>/reports/profitAnalysis/page0.jsp" method="post" class="row g-3 align-items-end">
        <!-- From Date -->
        <div class="col-md-3">
            <label for="fromDate" class="form-label">From Date:</label>
            <input type="date" id="fromDate" name="fromDate" value="<%=today%>" class="form-control" required>
        </div>

        <!-- To Date -->
        <div class="col-md-3">
            <label for="toDate" class="form-label">To Date:</label>
            <input type="date" id="toDate" name="toDate" value="<%=today%>" class="form-control" required>
        </div>

        <!-- Report Type -->
        <div class="col-md-3">
            <label for="reportType" class="form-label">Report Type:</label>
            <select id="reportType" name="reportType" class="form-select">
                <option value="netprofit" selected>Net Profit (Sales − Purchase − Expense)</option>
                <option value="product">Product-wise (Cost vs MRP)</option>
                <option value="bill">Bill-wise (Cost vs MRP)</option>
            </select>
        </div>

        <!-- Submit Button -->
        <div class="col-md-2">
            <button type="submit" class="bb bb-primary w-100">Generate Report</button>
        </div>
    </form>
</div>

</body>
</html>
