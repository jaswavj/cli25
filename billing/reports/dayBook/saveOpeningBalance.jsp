<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="javax.servlet.http.*"%>
<jsp:useBean id="billing" class="billing.billingBean" />
<%
response.setContentType("application/json;charset=UTF-8");
Integer uid = (Integer) session.getAttribute("userId");
if (uid == null) {
    out.print("{\"success\":false,\"message\":\"Session expired. Please login again.\"}");
    return;
}

try {
    String balanceDate = request.getParameter("balanceDate");
    String balanceType = request.getParameter("balanceType");
    String amountStr = request.getParameter("amount");
    String notes = request.getParameter("notes");

    if (balanceDate == null || balanceDate.trim().isEmpty()) {
        out.print("{\"success\":false,\"message\":\"Date is required.\"}");
        return;
    }
    if (amountStr == null || amountStr.trim().isEmpty()) {
        out.print("{\"success\":false,\"message\":\"Amount is required.\"}");
        return;
    }
    if (balanceType == null || balanceType.trim().isEmpty()) {
        balanceType = "cash";
    }

    double amount = Double.parseDouble(amountStr.trim());
    int newId = billing.saveDayBookOpeningBalance(balanceDate.trim(), amount, notes != null ? notes.trim() : "", balanceType.trim(), uid);
    out.print("{\"success\":true,\"message\":\"Opening balance saved successfully.\",\"id\":" + newId + "}");
} catch (NumberFormatException e) {
    out.print("{\"success\":false,\"message\":\"Invalid amount.\"}");
} catch (Exception e) {
    e.printStackTrace();
    String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'").replace("\\", "/") : "Save failed.";
    if (msg.toLowerCase().contains("daybook_opening_balance") || msg.toLowerCase().contains("doesn't exist") || msg.toLowerCase().contains("balance_type")) {
        msg = "Database update required. Please run database/daybook_opening_balance_add_type.sql first.";
    }
    out.print("{\"success\":false,\"message\":\"" + msg + "\"}");
}
%>
