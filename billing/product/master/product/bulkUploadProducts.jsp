<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, org.json.*"%>
<jsp:useBean id="prod" class="product.productBean" />
<%
response.setContentType("application/json;charset=UTF-8");
Integer uid = (Integer) session.getAttribute("userId");
if (uid == null) {
    out.print("{\"success\":false,\"message\":\"Session expired. Please login again.\"}");
    return;
}

try {
    StringBuilder sb = new StringBuilder();
    BufferedReader reader = request.getReader();
    String line;
    while ((line = reader.readLine()) != null) {
        sb.append(line);
    }

    JSONObject body = new JSONObject(sb.toString());
    JSONArray rows = body.getJSONArray("rows");
    if (rows.length() == 0) {
        out.print("{\"success\":false,\"message\":\"No product rows found in file.\"}");
        return;
    }

    int imported = 0;
    int failed = 0;
    JSONArray errors = new JSONArray();

    for (int i = 0; i < rows.length(); i++) {
        JSONObject row = rows.getJSONObject(i);
        int excelRow = i + 2;
        try {
            prod.importProductFromBulk(
                row.optString("category", ""),
                row.optString("brand", ""),
                row.optString("productName", ""),
                row.optString("productCode", ""),
                row.optString("unit", ""),
                row.optString("cost", ""),
                row.optString("mrp", ""),
                row.optString("stock", ""),
                row.optString("gst", ""),
                row.optString("hsn", ""),
                uid
            );
            imported++;
        } catch (Exception e) {
            failed++;
            String msg = e.getMessage() != null ? e.getMessage() : "Import failed.";
            errors.put("Row " + excelRow + ": " + msg);
        }
    }

    JSONObject result = new JSONObject();
    result.put("success", true);
    result.put("imported", imported);
    result.put("failed", failed);
    result.put("errors", errors);
    if (imported > 0 && failed == 0) {
        result.put("message", imported + " product(s) imported successfully.");
    } else if (imported > 0) {
        result.put("message", imported + " imported, " + failed + " failed.");
    } else {
        result.put("message", "No products imported. " + failed + " row(s) failed.");
    }
    out.print(result.toString());
} catch (Exception e) {
    e.printStackTrace();
    String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'") : "Upload failed.";
    out.print("{\"success\":false,\"message\":\"" + msg + "\"}");
}
%>
