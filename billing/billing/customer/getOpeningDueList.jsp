<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, org.json.*" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<%
response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");

Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) {
    out.print("[]");
    return;
}

String customerIdStr = request.getParameter("customerId");
if (customerIdStr == null || customerIdStr.trim().isEmpty()) {
    out.print("[]");
    return;
}

JSONArray results = new JSONArray();
try {
    int customerId = Integer.parseInt(customerIdStr.trim());
    Vector list = bill.getCustomerOpeningDueList(customerId);
    for (int i = 0; i < list.size(); i++) {
        Vector row = (Vector) list.get(i);
        JSONObject obj = new JSONObject();
        obj.put("id", row.get(0));
        obj.put("dueDate", row.get(1));
        obj.put("amount", row.get(2));
        obj.put("balanceAfter", row.get(3));
        obj.put("notes", row.get(4));
        obj.put("userName", row.get(5));
        obj.put("entryDate", row.get(6));
        obj.put("entryTime", row.get(7));
        results.put(obj);
    }
} catch (Exception e) {
    e.printStackTrace();
}

out.print(results.toString());
%>
