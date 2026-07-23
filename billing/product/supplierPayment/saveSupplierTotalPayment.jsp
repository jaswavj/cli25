<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<jsp:useBean id="bill" class="billing.billingBean" />
<%
Integer uid = (Integer) session.getAttribute("userId");
if (uid == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
}

String supIdParam = request.getParameter("supId");
String amountStr = request.getParameter("amount");
String modeStr = request.getParameter("mode");
String bankStr = request.getParameter("bankOption");

if (supIdParam == null || amountStr == null || amountStr.trim().isEmpty()) {
    response.sendRedirect(request.getContextPath() + "/product/supplierPayment/page.jsp?msg=Invalid+payment+details&type=danger");
    return;
}

try {
    int supId = Integer.parseInt(supIdParam);
    double amount = Double.parseDouble(amountStr.trim());
    int mode = modeStr != null && !modeStr.trim().isEmpty() ? Integer.parseInt(modeStr.trim()) : 1;
    int bankOption = bankStr != null && !bankStr.trim().isEmpty() ? Integer.parseInt(bankStr.trim()) : 0;
    bill.saveSupplierTotalBalancePayment(supId, amount, mode, bankOption, uid);
    response.sendRedirect(request.getContextPath() + "/product/supplierPayment/page1.jsp?supId=" + supId + "&msg=Payment+collected+successfully&type=success");
} catch (Exception e) {
    String err = e.getMessage() != null ? java.net.URLEncoder.encode(e.getMessage(), "UTF-8") : "Payment+failed";
    response.sendRedirect(request.getContextPath() + "/product/supplierPayment/page1.jsp?supId=" + supIdParam + "&msg=" + err + "&type=danger");
}
%>
