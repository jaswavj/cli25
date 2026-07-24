<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<jsp:useBean id="prod" class="product.productBean" />
<%
response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");

Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) {
    out.print("{\"success\":false,\"message\":\"Session expired.\"}");
    return;
}

String customerIdStr = request.getParameter("customerId");
if (customerIdStr == null || customerIdStr.trim().isEmpty()) {
    out.print("{\"success\":false,\"message\":\"Customer ID is required.\"}");
    return;
}

try {
    int customerId = Integer.parseInt(customerIdStr.trim());
    Vector custInfo = prod.getCustomerById(customerId);
    Vector account = bill.getCustomerAccount(customerId);

    String name = custInfo != null && custInfo.size() > 0 ? custInfo.get(0).toString() : "";
    String phone = custInfo != null && custInfo.size() > 1 ? custInfo.get(1).toString() : "-";

    double advance = 0;
    double balance = 0;
    if (account != null && account.size() >= 4) {
        try { advance = Double.parseDouble(account.get(2).toString()); } catch (Exception e) {}
        try { balance = Double.parseDouble(account.get(3).toString()); } catch (Exception e) {}
    }

    double netCollectable = Math.max(0, balance - advance);

    out.print("{"
        + "\"success\":true,"
        + "\"customerId\":" + customerId + ","
        + "\"name\":\"" + name.replace("\\", "\\\\").replace("\"", "\\\"") + "\","
        + "\"phone\":\"" + phone.replace("\\", "\\\\").replace("\"", "\\\"") + "\","
        + "\"advance\":" + advance + ","
        + "\"balance\":" + balance + ","
        + "\"netCollectable\":" + netCollectable
        + "}");
} catch (Exception e) {
    out.print("{\"success\":false,\"message\":\"" + e.getMessage().replace("\"", "'") + "\"}");
}
%>
