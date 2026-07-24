<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<%
response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");

Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) {
    out.print("{\"success\":false,\"message\":\"Session expired. Please login again.\"}");
    return;
}

try {
    String customerIdStr = request.getParameter("customerId");
    String dueDate = request.getParameter("dueDate");
    String amountStr = request.getParameter("amount");
    String notes = request.getParameter("notes");

    if (customerIdStr == null || customerIdStr.trim().isEmpty()) {
        out.print("{\"success\":false,\"message\":\"Customer is required.\"}");
        return;
    }
    if (dueDate == null || dueDate.trim().isEmpty()) {
        out.print("{\"success\":false,\"message\":\"Date is required.\"}");
        return;
    }
    if (amountStr == null || amountStr.trim().isEmpty()) {
        out.print("{\"success\":false,\"message\":\"Amount is required.\"}");
        return;
    }

    int customerId = Integer.parseInt(customerIdStr.trim());
    double amount = Double.parseDouble(amountStr.trim());
    double newBalance = bill.saveCustomerOpeningDue(
        customerId,
        dueDate.trim(),
        amount,
        notes != null ? notes.trim() : "",
        userId
    );

    out.print("{\"success\":true,\"message\":\"Opening due saved successfully.\",\"newBalance\":" + newBalance + "}");
} catch (NumberFormatException e) {
    out.print("{\"success\":false,\"message\":\"Invalid number format.\"}");
} catch (Exception e) {
    String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'").replace("\\", "/") : "Save failed.";
    if (msg.toLowerCase().contains("customer_opening_due") || msg.toLowerCase().contains("doesn't exist")) {
        msg = "Table not found. Please run database/customer_opening_due_setup.sql first.";
    }
    out.print("{\"success\":false,\"message\":\"" + msg + "\"}");
}
%>
