<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<%@ page errorPage="" %>
<jsp:useBean id="prod" class="product.productBean" />
<%
// Session check
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
}

// Get filter parameters
String filterName = request.getParameter("filterName");
String filterCategory = request.getParameter("filterCategory");
if (filterName == null) filterName = "";
if (filterCategory == null) filterCategory = "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Bulk Update MRP & GST - Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        .table td, .table th { vertical-align: middle; font-size: 0.9rem; }
    </style>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>
<%
    request.setAttribute("pageTitle",    "Bulk Update");
    request.setAttribute("pageSubtitle", "Product Master — Bulk Price Update");
    request.setAttribute("pageIcon",     "fa-solid fa-pen-to-square");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

<%
String msg = request.getParameter("msg");
String type = request.getParameter("type");
%>

<% if (msg != null) { %>
<div class="alert alert-<%= (type != null ? type : "info") %> alert-dismissible fade show mt-3 mx-3" role="alert">
  <%= msg %>
  <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
</div>
<% } %>

    <div class="container-fluid mt-2 mst-page" style="max-width: 1800px;">
        <!-- Filter Section -->
        <div class="mst-filter-card">
            <form method="get" action="<%=contextPath%>/product/master/productBulkUpdate/page.jsp" class="row g-2 align-items-end">
                <div class="col-md-4">
                    <label class="form-label" style="font-size: 0.85rem; margin-bottom: 0.25rem;">Filter by <%=head3%> Name</label>
                    <input type="text" name="filterName" class="form-control" placeholder="Enter product name..." value="<%=filterName%>">
                </div>
                <div class="col-md-4">
                    <label class="form-label" style="font-size: 0.85rem; margin-bottom: 0.25rem;">Filter by <%=head1%></label>
                    <select name="filterCategory" class="form-select">
                        <option value="">All Categories</option>
                        <%
                            Vector categories = prod.getCategoryName();
                            if (categories != null) {
                                for (int i = 0; i < categories.size(); i++) {
                                    Vector cat = (Vector) categories.get(i);
                                    if (cat != null && cat.elementAt(0) != null && cat.elementAt(1) != null) {
                                        String categoryName = cat.elementAt(0).toString();
                                        String categoryId = cat.elementAt(1).toString();
                                        String selected = categoryId.equals(filterCategory) ? "selected" : "";
                        %>
                            <option value="<%=categoryId%>" <%=selected%>><%=categoryName%></option>
                        <%      }
                                }
                            }
                        %>
                    </select>
                </div>
                <div class="col-md-2">
                    <button type="submit" class="bb bb-primary w-100">
                        <i class="fas fa-filter me-1"></i> Filter
                    </button>
                </div>
                <div class="col-md-2">
                    <a href="<%=contextPath%>/product/master/productBulkUpdate/page.jsp" class="bb bb-outline w-100">
                        <i class="fas fa-redo me-1"></i> Reset
                    </a>
                </div>
            </form>
        </div>

        <!-- Products Table -->
        <div class="card border-0 shadow-sm">
            <div class="table-responsive">
                <table class="table table-hover mb-0 mst-table" style="font-size:12.5px;">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th><%=head3%> Name</th>
                            <th>Brand</th>
                            <th><%=head1%></th>
                            <th style="width:110px;">Code</th>
                            <th style="width:100px;">Cost</th>
                            <th style="width:100px;">MRP</th>
                            <th style="width:80px;">GST %</th>
                            <th style="width:90px;">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            int count = 0;
                            try {
                                Vector products = prod.getProductsForBulkUpdate(filterName, filterCategory);
                                for (int i = 0; i < products.size(); i++) {
                                    Vector product = (Vector) products.get(i);
                                    count++;
                                    int    productId   = ((Integer) product.get(0)).intValue();
                                    String productName = (String)  product.get(1);
                                    String productCode = product.get(2) != null ? (String) product.get(2) : "";
                                    int    gst         = ((Integer) product.get(3)).intValue();
                                    String categoryName= (String)  product.get(4);
                                    double mrp         = ((Double)  product.get(5)).doubleValue();
                                    int    batchId     = ((Integer) product.get(6)).intValue();
                                    double cost        = ((Double)  product.get(7)).doubleValue();
                                    String brandName   = (String)  product.get(8);
                        %>
                        <tr id="row-<%=productId%>">
                            <td><%=count%></td>
                            <td><strong><%=productName%></strong></td>
                            <td style="color:#555;"><%=brandName != null ? brandName : "-"%></td>
                            <td><%=categoryName%></td>
                            <td>
                                <input type="text" class="form-control form-control-sm" id="code-<%=productId%>" value="<%=productCode%>" style="width:90px;padding:3px 5px;">
                            </td>
                            <td>
                                <input type="number" step="0.01" class="form-control form-control-sm" id="cost-<%=productId%>" value="<%=String.format("%.2f", cost)%>" min="0" style="width:90px;padding:3px 5px;">
                            </td>
                            <td>
                                <input type="number" step="0.01" class="form-control form-control-sm" id="mrp-<%=productId%>" value="<%=String.format("%.2f", mrp)%>" min="0" style="width:90px;padding:3px 5px;">
                            </td>
                            <td>
                                <input type="number" step="1" class="form-control form-control-sm" id="gst-<%=productId%>" value="<%=gst%>" min="0" max="100" style="width:65px;padding:3px 5px;">
                            </td>
                            <td>
                                <button class="bb bb-primary" style="height:30px;padding:0 10px;font-size:11px;" onclick="updateProduct(<%=productId%>, <%=batchId%>)">
                                    <i class="fas fa-save me-1"></i>Save
                                </button>
                            </td>
                        </tr>
                        <%
                                }
                                if (count == 0) {
                        %>
                        <tr>
                            <td colspan="9" class="text-center text-muted py-4">No products found matching your criteria</td>
                        </tr>
                        <%
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                        %>
                        <tr>
                            <td colspan="9" class="text-center text-danger py-4">Error loading products: <%=e.getMessage()%></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script>
        function updateProduct(productId, batchId) {
            const code = document.getElementById('code-' + productId).value.trim();
            const cost = document.getElementById('cost-' + productId).value;
            const mrp  = document.getElementById('mrp-'  + productId).value;
            const gst  = document.getElementById('gst-'  + productId).value;

            if (!mrp || parseFloat(mrp) < 0) {
                Swal.fire({ icon:'error', title:'Invalid MRP', text:'Please enter a valid MRP value.', confirmButtonColor:'#667eea' });
                return;
            }
            if (!cost || parseFloat(cost) < 0) {
                Swal.fire({ icon:'error', title:'Invalid Cost', text:'Please enter a valid cost value.', confirmButtonColor:'#667eea' });
                return;
            }
            if (gst === '' || parseInt(gst) < 0 || parseInt(gst) > 100) {
                Swal.fire({ icon:'error', title:'Invalid GST', text:'GST must be between 0 and 100.', confirmButtonColor:'#667eea' });
                return;
            }

            Swal.fire({
                title: 'Save Changes?',
                text: 'Update code, cost, MRP and GST for this product?',
                icon: 'question',
                showCancelButton: true,
                confirmButtonColor: '#667eea',
                cancelButtonColor: '#d33',
                confirmButtonText: 'Yes, save!'
            }).then((result) => {
                if (result.isConfirmed) {
                    Swal.fire({ title:'Saving...', allowOutsideClick:false, didOpen:() => Swal.showLoading() });

                    const form = document.createElement('form');
                    form.method = 'POST';
                    form.action = 'update.jsp';
                    const fields = { productId, batchId, code, cost, mrp, gst };
                    for (const key in fields) {
                        const inp = document.createElement('input');
                        inp.type = 'hidden'; inp.name = key; inp.value = fields[key];
                        form.appendChild(inp);
                    }
                    document.body.appendChild(form);
                    form.submit();
                }
            });
        }
    </script>
</body>
</html>

