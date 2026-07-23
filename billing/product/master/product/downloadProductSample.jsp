<%@ page language="java" contentType="application/vnd.ms-excel; charset=UTF-8" pageEncoding="UTF-8"%>
<%
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
}

response.setHeader("Content-Disposition", "attachment; filename=product_bulk_upload_sample.xls");
%>
<html xmlns:x="urn:schemas-microsoft-com:office:excel">
<head>
    <meta charset="UTF-8">
    <!--[if gte mso 9]><xml>
    <x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet>
    <x:Name>Products</x:Name>
    <x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions>
    </x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook>
    </xml><![endif]-->
    <style>
        th { background:#1e3a5f; color:#fff; font-weight:bold; }
        td, th { border:1px solid #ccc; padding:4px 8px; }
    </style>
</head>
<body>
<table>
    <tr>
        <th>Category</th>
        <th>Brand</th>
        <th>Product Name</th>
        <th>Product Code</th>
        <th>Unit</th>
        <th>Cost Price</th>
        <th>MRP</th>
        <th>Stock</th>
        <th>GST</th>
        <th>HSN</th>
    </tr>
    <tr>
        <td>Stationary</td>
        <td>Other</td>
        <td>Pencil</td>
        <td>101</td>
        <td>NOS</td>
        <td>8.000</td>
        <td>12.00</td>
        <td>100</td>
        <td>0</td>
        <td></td>
    </tr>
    <tr>
        <td>Stationary</td>
        <td>Other</td>
        <td>Gen Pen</td>
        <td>102</td>
        <td>NOS</td>
        <td>15.000</td>
        <td>25.00</td>
        <td>50</td>
        <td>0</td>
        <td></td>
    </tr>
    <tr>
        <td>Stationary</td>
        <td>Other</td>
        <td>A4 Notebook</td>
        <td>103</td>
        <td>NOS</td>
        <td>35.000</td>
        <td>50.00</td>
        <td>0</td>
        <td>5</td>
        <td></td>
    </tr>
</table>
<p style="color:#666;font-size:11px;">
    Notes: Category, Brand and Unit must exactly match names in master. Delete sample rows before upload or replace with your products.
</p>
</body>
</html>
