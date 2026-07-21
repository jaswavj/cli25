<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.text.SimpleDateFormat, java.util.Date"%>
<%
Integer uid = (Integer) session.getAttribute("userId");
if (uid == null) { response.sendRedirect(request.getContextPath() + "/index.jsp"); return; }
String today = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Balance Summary Report</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
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
    <form action="<%=contextPath%>/reports/balanceSummary/report.jsp" method="get" class="row g-3">
        <div class="col-md-3">
            <label class="form-label">From Date:</label>
            <input type="date" name="fromDate" value="<%=today%>" class="form-control" required>
        </div>
        <div class="col-md-3">
            <label class="form-label">To Date:</label>
            <input type="date" name="toDate" value="<%=today%>" class="form-control" required>
        </div>
        <div class="col-md-3 d-flex align-items-end">
            <button type="submit" class="bb bb-primary w-100">
                <i class="fas fa-search me-1"></i> Generate Report
            </button>
        </div>
    </form>
</div>
</body>
</html>
