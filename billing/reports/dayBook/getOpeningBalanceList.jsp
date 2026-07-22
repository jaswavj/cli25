<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, org.json.*"%>
<jsp:useBean id="billing" class="billing.billingBean" />
<%
response.setContentType("application/json;charset=UTF-8");
Integer uid = (Integer) session.getAttribute("userId");
if (uid == null) {
    out.print("[]");
    return;
}

JSONArray arr = new JSONArray();
try {
    Vector list = billing.getDayBookOpeningBalanceList();
    for (int i = 0; i < list.size(); i++) {
        Vector row = (Vector) list.get(i);
        JSONObject obj = new JSONObject();
        obj.put("id", row.get(0).toString());
        obj.put("balanceDate", row.get(1).toString());
        obj.put("amount", row.get(2).toString());
        obj.put("balanceType", row.get(3).toString());
        obj.put("notes", row.get(4).toString());
        obj.put("userName", row.get(5).toString());
        obj.put("entryDate", row.get(6).toString());
        obj.put("entryTime", row.get(7).toString());
        arr.put(obj);
    }
} catch (Exception e) {
    // table may not exist yet
}
out.print(arr.toString());
%>
