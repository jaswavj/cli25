<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<jsp:useBean id="prod" class="product.productBean" />
<%
Integer uid = (Integer) session.getAttribute("userId");
if (uid == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
}

String supIdParam = request.getParameter("supId");
String amountStr = request.getParameter("amount");
String notes = request.getParameter("notes");

if (supIdParam == null || amountStr == null || amountStr.trim().isEmpty()) {
    response.sendRedirect(request.getContextPath() + "/product/supplierPayment/page.jsp?msg=Amount+is+required&type=danger");
    return;
}

try {
    int supId = Integer.parseInt(supIdParam);
    double amount = Double.parseDouble(amountStr.trim());
    prod.addSupplierOpeningBalance(supId, amount, notes != null ? notes : "", uid);
    response.sendRedirect(request.getContextPath() + "/product/supplierPayment/page1.jsp?supId=" + supId + "&msg=Old+balance+added+successfully&type=success");
} catch (Exception e) {
    String err = e.getMessage() != null ? e.getMessage().replace(" ", "+") : "Save+failed";
    String redirectSup = supIdParam != null ? ("&supId=" + supIdParam) : "";
    if (supIdParam != null) {
        response.sendRedirect(request.getContextPath() + "/product/supplierPayment/page1.jsp?supId=" + supIdParam + "&msg=" + err + "&type=danger");
    } else {
        response.sendRedirect(request.getContextPath() + "/product/supplierPayment/page.jsp?msg=" + err + "&type=danger");
    }
}
%>
