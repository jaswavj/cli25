<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, org.json.*" %>
<jsp:useBean id="prod" class="product.productBean" />
<%
response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");

String query = request.getParameter("query");
String phone = request.getParameter("phone");
JSONArray results = new JSONArray();

try {
    Vector suppliers;
    if (phone != null && !phone.trim().isEmpty()) {
        suppliers = prod.searchSuppliersByPhone(phone.trim());
    } else if (query != null && !query.trim().isEmpty()) {
        suppliers = prod.searchSuppliers(query.trim());
    } else {
        out.print(results.toString());
        return;
    }

    for (int i = 0; i < suppliers.size(); i++) {
        Vector row = (Vector) suppliers.get(i);
        JSONObject obj = new JSONObject();
        obj.put("id", row.get(0));
        obj.put("name", row.get(1));
        obj.put("phone", row.get(2));
        results.put(obj);
    }
} catch (Exception e) {
    e.printStackTrace();
}

out.print(results.toString());
%>
