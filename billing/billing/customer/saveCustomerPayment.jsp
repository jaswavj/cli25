<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<%
response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");

try {
    // Auth check
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        out.print("{\"success\":false,\"message\":\"Session expired. Please login again.\"}");
        return;
    }

    String custIdStr  = request.getParameter("customerId");
    String cashStr    = request.getParameter("cashPaid");
    String bankStr    = request.getParameter("bankPaid");
    String modeStr    = request.getParameter("payMode");
    String typeStr    = request.getParameter("payType");

    if (custIdStr == null || modeStr == null) {
        out.print("{\"success\":false,\"message\":\"Missing required parameters.\"}");
        return;
    }

    int    customerId = Integer.parseInt(custIdStr.trim());
    double cashPaid   = (cashStr != null && !cashStr.trim().isEmpty()) ? Double.parseDouble(cashStr.trim()) : 0;
    double bankPaid   = (bankStr != null && !bankStr.trim().isEmpty()) ? Double.parseDouble(bankStr.trim()) : 0;
    int    payMode    = Integer.parseInt(modeStr.trim());
    int    payType    = (typeStr != null && !typeStr.trim().isEmpty()) ? Integer.parseInt(typeStr.trim()) : 0;

    if (cashPaid < 0 || bankPaid < 0) {
        out.print("{\"success\":false,\"message\":\"Payment amounts cannot be negative.\"}");
        return;
    }
    double total = cashPaid + bankPaid;
    if (total <= 0) {
        out.print("{\"success\":false,\"message\":\"Payment amount must be greater than zero.\"}");
        return;
    }

    double newBalance = bill.saveCustomerPayment(customerId, cashPaid, bankPaid, payMode, payType, userId);

    out.print("{\"success\":true,\"newBalance\":" + newBalance + "}");

} catch (NumberFormatException e) {
    out.print("{\"success\":false,\"message\":\"Invalid number format: " + e.getMessage().replace("\"","'") + "\"}");
} catch (Exception e) {
    out.print("{\"success\":false,\"message\":\"" + e.getMessage().replace("\"","'") + "\"}");
}
%>
