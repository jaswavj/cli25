<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<jsp:useBean id="prod" class="product.productBean" />
<%
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
}

String productIdStr = request.getParameter("productId");
String batchIdStr   = request.getParameter("batchId");
String code         = request.getParameter("code");
String costStr      = request.getParameter("cost");
String mrpStr       = request.getParameter("mrp");
String gstStr       = request.getParameter("gst");

if (productIdStr == null || batchIdStr == null || mrpStr == null || gstStr == null || costStr == null) {
    response.sendRedirect(request.getContextPath() + "/product/master/productBulkUpdate/page.jsp?msg=Missing required parameters&type=danger");
    return;
}

try {
    int    productId = Integer.parseInt(productIdStr);
    int    batchId   = Integer.parseInt(batchIdStr);
    double cost      = Double.parseDouble(costStr);
    double mrp       = Double.parseDouble(mrpStr);
    int    gst       = Integer.parseInt(gstStr);

    if (mrp < 0) {
        response.sendRedirect(request.getContextPath() + "/product/master/productBulkUpdate/page.jsp?msg=Invalid MRP value&type=danger");
        return;
    }
    if (cost < 0) {
        response.sendRedirect(request.getContextPath() + "/product/master/productBulkUpdate/page.jsp?msg=Invalid cost value&type=danger");
        return;
    }
    if (gst < 0 || gst > 100) {
        response.sendRedirect(request.getContextPath() + "/product/master/productBulkUpdate/page.jsp?msg=Invalid GST value (must be 0-100)&type=danger");
        return;
    }

    boolean success = prod.bulkUpdateProduct(productId, batchId, code, cost, mrp, gst);

    if (success) {
        response.sendRedirect(request.getContextPath() + "/product/master/productBulkUpdate/page.jsp?msg=Product updated successfully!&type=success");
    } else {
        response.sendRedirect(request.getContextPath() + "/product/master/productBulkUpdate/page.jsp?msg=Failed to update product&type=danger");
    }

} catch (NumberFormatException e) {
    response.sendRedirect(request.getContextPath() + "/product/master/productBulkUpdate/page.jsp?msg=Invalid number format&type=danger");
} catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect(request.getContextPath() + "/product/master/productBulkUpdate/page.jsp?msg=Error: " + e.getMessage() + "&type=danger");
}
%>
