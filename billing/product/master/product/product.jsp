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
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Products - Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
    <!-- Bootstrap CSS -->
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        .table td, .table th { vertical-align: middle; }
        @media (max-width: 768px) {
            .card-header .input-group { width: 100% !important; margin-top: 0.5rem; }
            .card-header .d-flex { flex-direction: column; align-items: stretch !important; }
            .card-header h6 { margin-bottom: 0.5rem; }
        }
    </style>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>
<%
    request.setAttribute("pageTitle",    "Products");
    request.setAttribute("pageSubtitle", "Product Master — Products");
    request.setAttribute("pageIcon",     "fa-solid fa-box");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />
<%
String msg = request.getParameter("msg");
String type = request.getParameter("type"); // success / warning / danger / info
%>

<% if (msg != null) { %>
<div class="alert alert-<%= (type != null ? type : "info") %> alert-dismissible fade show mt-3" role="alert">
  <%= msg %>
  <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
</div>
<% } %>

    <div class="container-fluid mt-2 mst-page" style="max-width: 1600px;">
        <!-- Bulk Upload -->
        <div class="card mb-2" style="border: none; box-shadow: 0 2px 4px rgba(0,0,0,.07); border-radius: 8px;">
            <div class="mst-card-header-light py-2 px-3">
                <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                    <h6 class="mb-0" style="font-size: 0.95rem;">
                        <i class="fas fa-file-excel me-2"></i>Bulk Upload <%=head3%>
                    </h6>
                    <div class="d-flex flex-wrap gap-2 align-items-center">
                        <a href="<%=contextPath%>/product/master/product/downloadProductSample.jsp" class="bb bb-green btn-sm">
                            <i class="fas fa-download me-1"></i>Download Sample Excel
                        </a>
                        <input type="file" id="bulkUploadFile" class="form-control form-control-sm" style="max-width:260px;" accept=".xlsx,.xls,.csv">
                        <button type="button" id="bulkUploadBtn" class="bb bb-primary btn-sm" onclick="uploadBulkProducts()">
                            <i class="fas fa-upload me-1"></i>Upload Excel
                        </button>
                    </div>
                </div>
            </div>
            <div class="card-body py-2 px-3">
                <small class="text-muted">
                    Excel columns: <strong>Category, Brand, Product Name, Product Code, Unit, Cost Price, MRP, Stock, GST, HSN</strong>.
                    Category / Brand / Unit names must match master exactly.
                </small>
            </div>
        </div>

        <div class="row g-2">
            <!-- Left Column - Add Product Form -->
            <div class="col-md-5">
                <div class="card" style="border: none; box-shadow: 0 2px 4px rgba(0,0,0,.07); border-radius: 8px;">
                    <div class="mst-card-header">
                        <h6 class="mb-0" style="font-size: 0.95rem;"><i class="fas fa-plus-circle me-2"></i>Add New <%=head3%></h6>
                    </div>
                    <div class="card-body" style="padding: 1rem;">
                        <form id="productForm" action="<%=contextPath%>/product/master/product/product1.jsp" method="post" class="row g-2">
                            <input type="hidden" name="productId" id="editProductId" value="0">
                            <input type="hidden" name="hsn" value="">
                            <input type="hidden" name="commission" value="0.00">
                            <input type="hidden" name="discType" value="0">
                            <input type="hidden" name="discValue" value="0.00">
                            <input type="hidden" name="gst" value="0">
                            <div class="col-md-6">
                                <label style="font-size: 0.85rem;"><%=head1%> <span style="color:red">*</span></label>
                                <select name="categoryId" class="form-select" style="padding: 7px 10px; font-size: 0.9rem;" required>
                                    <option value="">Select <%=head1%></option>
                                    <%
                                        Vector categories = prod.getCategoryName();
                                        if (categories != null) {
                                            for (int i = 0; i < categories.size(); i++) {
                                                Vector cat = (Vector) categories.get(i);
                                                if (cat != null && cat.elementAt(0) != null && cat.elementAt(1) != null) {
                                                    String categoryName = cat.elementAt(0).toString();
                                                    String categoryId = cat.elementAt(1).toString();
                                    %>
                                        <option value="<%=categoryId%>"><%=categoryName%></option>
                                    <%      }
                                            }
                                        }
                                    %>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label style="font-size: 0.85rem;"><%=head2%> <span style="color:red">*</span></label>
                                <select name="brandId" class="form-select" style="padding: 7px 10px; font-size: 0.9rem;" required>
                                    <option value="">Select <%=head2%></option>
                                    <%
                                        Vector brands = prod.getBrandsName();
                                        String othersBrandId = "";
                                        if (brands != null) {
                                            for (int i = 0; i < brands.size(); i++) {
                                                Vector brand = (Vector) brands.get(i);
                                                if (brand != null && brand.elementAt(0) != null && brand.elementAt(1) != null) {
                                                    String brandName = brand.elementAt(0).toString();
                                                    String brandId = brand.elementAt(1).toString();
                                                    if (brandName.equalsIgnoreCase("others") || brandName.equalsIgnoreCase("other")) {
                                                        othersBrandId = brandId;
                                                    }
                                    %>
                                        <option value="<%=brandId%>" <%=brandId.equals(othersBrandId) && !othersBrandId.isEmpty() ? "selected" : ""%>><%=brandName%></option>
                                    <%      }
                                            }
                                        }
                                    %>
                                </select>
                            </div>
                            <div class="col-md-12">
                                <label style="font-size: 0.85rem;"><%=head3%> Name <span style="color:red">*</span></label><input type="text" name="productName" class="form-control" placeholder="" style="padding: 7px 10px; font-size: 0.9rem;" required>
                            </div>
                            <div class="col-md-6 ">
                                <label style="font-size: 0.85rem;"><%=head3%> Code <span style="color:red">*</span></label><input type="text" name="productCode" class="form-control" placeholder="" style="padding: 7px 10px; font-size: 0.9rem;" >
                            </div>
                            
                            <div class="col-md-6">
                                <label style="font-size: 0.85rem;">Unit/Size</label>
                                <select name="unitId" id="unitSelect" class="form-select" style="padding: 7px 10px; font-size: 0.9rem;" onchange="handleUnitChange(this)" required>
                                    <option value="">Select Unit/Size</option>
                                    <%
                                        Vector units = prod.getUnits();
                                        if (units != null) {
                                            for (int i = 0; i < units.size(); i++) {
                                                Vector unit = (Vector) units.get(i);
                                                if (unit != null && unit.elementAt(0) != null && unit.elementAt(1) != null) {
                                                    String unitName = unit.elementAt(0).toString();
                                                    String unitId = unit.elementAt(1).toString();
                                                    String convertionUnit = (unit.size() > 2 && unit.elementAt(2) != null) ? unit.elementAt(2).toString() : "";
                                                    String convertionCalculation = (unit.size() > 3 && unit.elementAt(3) != null) ? unit.elementAt(3).toString() : "";
                                                    String selected = (unitName.equalsIgnoreCase("Nos") || unitName.equalsIgnoreCase("NOS") || unitName.equalsIgnoreCase("PCS")) ? "selected" : "";
                                    %>
                                        <option value="<%=unitId%>" data-convertion-unit="<%=convertionUnit%>" data-convertion-calculation="<%=convertionCalculation%>" <%=selected%>><%=unitName%></option>
                                    <%      }
                                            }
                                        }
                                    %>
                                </select>
                            </div>
                            
                            <div class="col-md-6 ">
                                <label id="costPriceLabel" style="font-size: 0.85rem;">Cost Price <span style="color:red">*</span></label><input type="number" step="0.001" name="cost" id="costInput" class="form-control" placeholder="0.000" style="padding: 7px 10px; font-size: 0.9rem;" required>
                                <small id="costConversionNote" class="text-muted d-block mt-1"></small>
                            </div>
                            <div class="col-md-6 ">
                                <label id="mrpLabel" style="font-size: 0.85rem;">MRP <span style="color:red">*</span></label><input type="number" step="0.001" name="mrp" id="mrpInput" class="form-control" placeholder="0.000" style="padding: 7px 10px; font-size: 0.9rem;" required>
                                <small id="mrpConversionNote" class="text-muted d-block mt-1"></small>
                            </div>
                            <div class="col-md-12">
                                <label id="stockLabel" style="font-size: 0.85rem;">Opening Stock</label>
                                <input type="number" step="0.001" name="stock" id="stockInput" class="form-control" placeholder="0" value="0" min="0" style="padding: 7px 10px; font-size: 0.9rem;">
                                <small id="stockConversionNote" class="text-muted d-block mt-1"></small>
                            </div>
                            <div class="col-md-12 mt-2 d-flex gap-2">
                                <button type="submit" id="submitBtn" class="bb bb-primary flex-grow-1">
                                    <i class="fas fa-save me-1" id="submitBtnIcon"></i><span id="submitBtnText">Add <%=head3%></span>
                                </button>
                                <button type="button" id="cancelEditBtn" class="bb bb-outline" style="display: none;" onclick="resetForm()">
                                    <i class="fas fa-times me-1"></i>Cancel
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Right Column - Product List Table -->
            <div class="col-md-7">
                <div class="card" style="border: none; box-shadow: 0 2px 4px rgba(0,0,0,.07); border-radius: 8px;">
                    <div class="mst-card-header-light">
                        <div class="d-flex justify-content-between align-items-center">
                            <h6 class="mb-0" style="font-size: 0.95rem;"><i class="fas fa-list me-2"></i><%=head3%> List</h6>
                            <div class="input-group" style="width: 300px;">
                                <span class="input-group-text"><i class="fas fa-search"></i></span>
                                <input type="text" id="productSearch" class="form-control mst-search-input" placeholder="Search products...">
                            </div>
                        </div>
                    </div>
                    <div class="card-body" style="padding: 0; max-height: 380px; overflow-y: auto; overflow-x: auto;">
                        <div class="table-responsive">
                        <table class="table table-hover mb-0 mst-table" style="table-layout: fixed; width: 100%; min-width: 600px;">
                            <thead style="position: sticky; top: 0; z-index: 10;">
                                <tr>
                                    <th style="width: 5%;">#</th>
                                    <th style="text-align: center; width: 10%;">Action</th>
                                    <th style="width: 18%;">Name</th>
                                    <th style="width: 10%;">Code</th>
                                    <th style="width: 12%;"><%=head1%></th>
                                    <th style="width: 10%;">MRP</th>
                                    <th style="width: 10%;">Stock</th>
                                </tr>
                            </thead>
                            <tbody id="productTableBody">
                                <tr>
                                    <td colspan="7" class="text-center" style="padding: 2rem;">
                                        <div class="spinner-border text-primary" role="status">
                                            <span class="visually-hidden">Loading...</span>
                                        </div>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                        </div>
                    </div>
                    <div class="card-footer" style="background: white; border-top: 1px solid #f7fafc; padding: 0.75rem 1rem;">
                        <div class="d-flex justify-content-between align-items-center">
                            <div id="productInfo" style="font-size: 0.85rem; color: #718096;">
                                Loading...
                            </div>
                            <nav>
                                <ul class="pagination pagination-sm mb-0" id="pagination" style="font-size: 0.8rem;">
                                    <!-- Pagination buttons will be inserted here -->
                                </ul>
                            </nav>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>

    <script>
    const contextPath = '<%=contextPath%>';

    function updateConvertedPriceNotes() {
        const unitSelect = document.getElementById('unitSelect');
        const costInput = document.getElementById('costInput');
        const mrpInput = document.getElementById('mrpInput');
        const stockInput = document.getElementById('stockInput');
        const costNote = document.getElementById('costConversionNote');
        const mrpNote = document.getElementById('mrpConversionNote');
        const stockNote = document.getElementById('stockConversionNote');
        if (!unitSelect || !costInput || !mrpInput || !costNote || !mrpNote) return;

        const selectedOption = unitSelect.options[unitSelect.selectedIndex];
        if (!selectedOption || unitSelect.value === '') {
            costNote.textContent = '';
            mrpNote.textContent = '';
            if (stockNote) stockNote.textContent = '';
            return;
        }

        const convertionUnit = selectedOption.getAttribute('data-convertion-unit') || '';
        const convertionCalculation = parseFloat(selectedOption.getAttribute('data-convertion-calculation') || '0');
        const costValue = parseFloat(costInput.value || '0');
        const mrpValue = parseFloat(mrpInput.value || '0');
        const stockValue = stockInput ? parseFloat(stockInput.value || '0') : 0;

        if (convertionUnit.trim() === '' || isNaN(convertionCalculation) || convertionCalculation <= 0) {
            costNote.textContent = '';
            mrpNote.textContent = '';
            if (stockNote) stockNote.textContent = '';
            return;
        }

        if (!isNaN(costValue) && costValue > 0) {
            const convertedCost = costValue / convertionCalculation;
            costNote.textContent = 'Converted Cost per ' + convertionUnit + ': ' + convertedCost.toFixed(3);
        } else {
            costNote.textContent = '';
        }

        if (!isNaN(mrpValue) && mrpValue > 0) {
            const convertedMrp = mrpValue / convertionCalculation;
            mrpNote.textContent = 'Converted MRP per ' + convertionUnit + ': ' + convertedMrp.toFixed(3);
        } else {
            mrpNote.textContent = '';
        }

        if (stockNote && !isNaN(stockValue) && stockValue > 0) {
            const convertedStock = stockValue * convertionCalculation;
            stockNote.textContent = 'Stored stock in ' + convertionUnit + ': ' + convertedStock.toFixed(3);
        } else if (stockNote) {
            stockNote.textContent = '';
        }
    }

    function handleUnitChange(select) {
        const selectedText = select.options[select.selectedIndex].text;
        const costPriceLabel = document.getElementById('costPriceLabel');
        const mrpLabel = document.getElementById('mrpLabel');
        const stockLabel = document.getElementById('stockLabel');
        
        if (select.value === "") {
            costPriceLabel.innerHTML = 'Cost Price <span style="color:red">*</span>';
            mrpLabel.innerHTML = 'MRP <span style="color:red">*</span>';
            if (stockLabel) stockLabel.textContent = "Opening Stock";
        } else {
            costPriceLabel.innerHTML = 'Cost Price per ' + selectedText + ' <span style="color:red">*</span>';
            mrpLabel.innerHTML = 'MRP per ' + selectedText + ' <span style="color:red">*</span>';
            if (stockLabel) stockLabel.textContent = 'Opening Stock (' + selectedText + ')';
        }

        updateConvertedPriceNotes();
    }

    // Pagination and search variables
    let currentPage = 1;
    let currentSearch = '';
    let searchTimeout = null;

    // Load products with pagination and search
    function loadProducts(page = 1, search = '') {
        currentPage = page;
        currentSearch = search;

        const tbody = document.getElementById('productTableBody');
        tbody.innerHTML = `
            <tr>
                <td colspan="7" class="text-center" style="padding: 2rem;">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Loading...</span>
                    </div>
                </td>
            </tr>
        `;

        fetch(contextPath + '/product/master/product/getProducts.jsp?page=' + page + '&search=' + encodeURIComponent(search))
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    displayProducts(data);
                    updatePagination(data);
                } else {
                    tbody.innerHTML = `
                        <tr>
                            <td colspan="7" class="text-center text-danger" style="padding: 2rem;">
                                Error: ${data.error || 'Failed to load products'}
                            </td>
                        </tr>
                    `;
                }
            })
            .catch(error => {
                console.error('Error loading products:', error);
                tbody.innerHTML = `
                    <tr>
                        <td colspan="7" class="text-center text-danger" style="padding: 2rem;">
                            Error loading products. Please try again.
                        </td>
                    </tr>
                `;
            });
    }

    // Display products in table
    function displayProducts(data) {
        const tbody = document.getElementById('productTableBody');
        
        if (data.products.length === 0) {
            tbody.innerHTML = `
                <tr>
                    <td colspan="7" class="text-center" style="padding: 2rem; color: #718096;">
                        <i class="fas fa-inbox fa-3x mb-3" style="opacity: 0.3;"></i>
                        <p class="mb-0">No products found. ${currentSearch ? 'Try a different search term.' : 'Add your first product above.'}</p>
                    </td>
                </tr>
            `;
            document.getElementById('productInfo').textContent = 'No products found';
            return;
        }

        let html = '';
        data.products.forEach(product => {
            html += `
                <tr style="border-bottom: 1px solid #f1f5f9; transition: all 0.2s;">
                    <td style="padding: 0.4rem; color: #718096; border: none; width: 5%;">${product.index}</td>
                    <td style="padding: 0.4rem; text-align: center; border: none; width: 10%;">
                        <button onclick="populateForm(${JSON.stringify(product).replace(/"/g, '&quot;')})" class="btn btn-sm" style="background: var(--primary-gradient); color: white; padding: 3px 10px; border-radius: 5px; border: none; font-weight: 500; font-size: 0.8rem;">
                            <i class="fas fa-edit me-1"></i>Edit
                        </button>
                    </td>
                    <td style="padding: 0.4rem; color: #2d3748; font-weight: 500; border: none; width: 18%; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="${product.productName}">${product.productName}</td>
                    <td style="padding: 0.4rem; color: #718096; border: none; width: 10%;"><span class="badge bg-secondary">${product.prodCode || '-'}</span></td>
                    <td style="padding: 0.4rem; color: #718096; border: none; width: 12%;">${product.categ}</td>
                    <td style="padding: 0.4rem; color: #718096; border: none; width: 10%;">${product.mrp}</td>
                    <td style="padding: 0.4rem; color: #718096; border: none; width: 10%;">${product.stock}${product.convertionUnit ? ' <small class="text-muted">' + product.convertionUnit + '</small>' : ' ' + (product.unit || '')}</td>
                </tr>
            `;
        });

        tbody.innerHTML = html;

        // Update product info
        const start = (data.currentPage - 1) * data.pageSize + 1;
        const end = Math.min(data.currentPage * data.pageSize, data.totalProducts);
        document.getElementById('productInfo').textContent = `Showing ${start}-${end} of ${data.totalProducts} products`;
    }

    // Update pagination controls
    function updatePagination(data) {
        const pagination = document.getElementById('pagination');
        let html = '';

        // Previous button
        if (data.currentPage > 1) {
            html += `
                <li class="page-item">
                    <a class="page-link" href="javascript:void(0)" onclick="loadProducts(${data.currentPage - 1}, '${currentSearch}')">
                        <i class="fas fa-chevron-left"></i>
                    </a>
                </li>
            `;
        } else {
            html += `
                <li class="page-item disabled">
                    <span class="page-link"><i class="fas fa-chevron-left"></i></span>
                </li>
            `;
        }

        // Page numbers
        const maxPagesToShow = 5;
        let startPage = Math.max(1, data.currentPage - Math.floor(maxPagesToShow / 2));
        let endPage = Math.min(data.totalPages, startPage + maxPagesToShow - 1);

        // Adjust start page if we're near the end
        if (endPage - startPage < maxPagesToShow - 1) {
            startPage = Math.max(1, endPage - maxPagesToShow + 1);
        }

        // First page
        if (startPage > 1) {
            html += `
                <li class="page-item">
                    <a class="page-link" href="javascript:void(0)" onclick="loadProducts(1, '${currentSearch}')">1</a>
                </li>
            `;
            if (startPage > 2) {
                html += `<li class="page-item disabled"><span class="page-link">...</span></li>`;
            }
        }

        // Page numbers
        for (let i = startPage; i <= endPage; i++) {
            if (i === data.currentPage) {
                html += `
                    <li class="page-item active">
                        <span class="page-link">${i}</span>
                    </li>
                `;
            } else {
                html += `
                    <li class="page-item">
                        <a class="page-link" href="javascript:void(0)" onclick="loadProducts(${i}, '${currentSearch}')">${i}</a>
                    </li>
                `;
            }
        }

        // Last page
        if (endPage < data.totalPages) {
            if (endPage < data.totalPages - 1) {
                html += `<li class="page-item disabled"><span class="page-link">...</span></li>`;
            }
            html += `
                <li class="page-item">
                    <a class="page-link" href="javascript:void(0)" onclick="loadProducts(${data.totalPages}, '${currentSearch}')">${data.totalPages}</a>
                </li>
            `;
        }

        // Next button
        if (data.currentPage < data.totalPages) {
            html += `
                <li class="page-item">
                    <a class="page-link" href="javascript:void(0)" onclick="loadProducts(${data.currentPage + 1}, '${currentSearch}')">
                        <i class="fas fa-chevron-right"></i>
                    </a>
                </li>
            `;
        } else {
            html += `
                <li class="page-item disabled">
                    <span class="page-link"><i class="fas fa-chevron-right"></i></span>
                </li>
            `;
        }

        pagination.innerHTML = html;
    }

    // Product search functionality with debouncing
    document.getElementById('costInput').addEventListener('input', updateConvertedPriceNotes);
    document.getElementById('mrpInput').addEventListener('input', updateConvertedPriceNotes);
    document.getElementById('stockInput').addEventListener('input', updateConvertedPriceNotes);

    document.getElementById('productSearch').addEventListener('input', function() {
        const searchTerm = this.value.trim();
        
        // Clear previous timeout
        if (searchTimeout) {
            clearTimeout(searchTimeout);
        }
        
        // Set new timeout to avoid too many requests
        searchTimeout = setTimeout(() => {
            loadProducts(1, searchTerm); // Reset to page 1 when searching
        }, 500); // Wait 500ms after user stops typing
    });

    // Populate form for editing
    function populateForm(product) {
        document.getElementById('editProductId').value = product.productId;
        document.getElementById('productForm').action = 'edit1.jsp';

        // Set form field values
        const form = document.getElementById('productForm');
        form.querySelector('[name="productName"]').value = product.productName || '';
        form.querySelector('[name="productCode"]').value = product.prodCode || '';

        // Set category dropdown
        const catSelect = form.querySelector('[name="categoryId"]');
        for (let opt of catSelect.options) {
            if (opt.text === product.categ) { opt.selected = true; break; }
        }

        // Set brand dropdown
        const brandSelect = form.querySelector('[name="brandId"]');
        for (let opt of brandSelect.options) {
            if (opt.text === product.brandss) { opt.selected = true; break; }
        }

        // Set unit dropdown
        const unitSelect = form.querySelector('[name="unitId"]');
        for (let opt of unitSelect.options) {
            if (opt.value == product.unitId) { opt.selected = true; break; }
        }

        // In edit mode, show values in selected unit if conversion exists.
        const selectedUnitOption = unitSelect.options[unitSelect.selectedIndex];
        const convertionCalculation = selectedUnitOption ? parseFloat(selectedUnitOption.getAttribute('data-convertion-calculation') || '0') : 0;
        const parsedCost = parseFloat(product.cost || '0');
        const parsedMrp = parseFloat(product.mrp || '0');
        const editCost = (!isNaN(convertionCalculation) && convertionCalculation > 0 && !isNaN(parsedCost)) ? (parsedCost * convertionCalculation) : parsedCost;
        const editMrp = (!isNaN(convertionCalculation) && convertionCalculation > 0 && !isNaN(parsedMrp)) ? (parsedMrp * convertionCalculation) : parsedMrp;
        form.querySelector('[name="cost"]').value = !isNaN(editCost) ? editCost : '';
        form.querySelector('[name="mrp"]').value = !isNaN(editMrp) ? editMrp : '';
        const parsedStock = parseFloat(product.stock || '0');
        const editStock = (!isNaN(convertionCalculation) && convertionCalculation > 0 && !isNaN(parsedStock))
            ? (parsedStock / convertionCalculation) : parsedStock;
        form.querySelector('[name="stock"]').value = !isNaN(editStock) ? editStock : '0';

        handleUnitChange(unitSelect);

        // Update button
        document.getElementById('submitBtnText').textContent = 'Update';
        document.getElementById('submitBtnIcon').className = 'fas fa-pen me-1';
        document.getElementById('submitBtn').classList.remove('btn-primary');
        document.getElementById('submitBtn').classList.add('btn-success');
        document.getElementById('cancelEditBtn').style.display = 'inline-block';

        // Update card header
        document.querySelector('.card-header h6').innerHTML = '<i class="fas fa-edit me-2"></i>Edit ' + (product.productName || '');

        // Scroll to top
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }

    // Reset form back to Add mode
    function resetForm() {
        document.getElementById('editProductId').value = '0';
        document.getElementById('productForm').action = 'product1.jsp';
        document.getElementById('productForm').reset();

        // Reset button
        document.getElementById('submitBtnText').textContent = 'Add';
        document.getElementById('submitBtnIcon').className = 'fas fa-save me-1';
        document.getElementById('submitBtn').classList.remove('btn-success');
        document.getElementById('submitBtn').classList.add('btn-primary');
        document.getElementById('cancelEditBtn').style.display = 'none';

        // Reset card header
        document.querySelector('.card-header h6').innerHTML = '<i class="fas fa-plus-circle me-2"></i>Add New Product';

        // Reset labels
        document.getElementById('costPriceLabel').innerHTML = 'Cost Price <span style="color:red">*</span>';
        document.getElementById('mrpLabel').innerHTML = 'MRP <span style="color:red">*</span>';
        document.getElementById('stockLabel').textContent = 'Opening Stock';
        document.getElementById('costConversionNote').textContent = '';
        document.getElementById('mrpConversionNote').textContent = '';
        document.getElementById('stockConversionNote').textContent = '';
        document.getElementById('stockInput').value = '0';

        // Re-select defaults (NOS unit, Others brand)
        const unitSelect = document.querySelector('[name="unitId"]');
        for (let opt of unitSelect.options) {
            if (opt.text === 'NOS' || opt.text === 'Nos' || opt.text === 'PCS') { opt.selected = true; break; }
        }
        const brandSelect = document.querySelector('[name="brandId"]');
        for (let opt of brandSelect.options) {
            if (opt.text.toLowerCase() === 'others' || opt.text.toLowerCase() === 'other') { opt.selected = true; break; }
        }

        handleUnitChange(unitSelect);
        updateConvertedPriceNotes();
    }

    // Load products on page load
    document.addEventListener('DOMContentLoaded', function() {
        loadProducts(1, '');
        handleUnitChange(document.getElementById('unitSelect'));
        updateConvertedPriceNotes();
    });

    function normalizeBulkHeader(h) {
        return String(h || '').trim().toLowerCase().replace(/[^a-z0-9]/g, '');
    }

    function parseCsvText(text) {
        const lines = text.replace(/^\uFEFF/, '').split(/\r?\n/).filter(l => l.trim() !== '');
        return lines.map(line => {
            const cells = [];
            let cur = '';
            let inQuote = false;
            for (let i = 0; i < line.length; i++) {
                const ch = line[i];
                if (ch === '"') {
                    inQuote = !inQuote;
                    continue;
                }
                if ((ch === ',' || ch === '\t') && !inQuote) {
                    cells.push(cur.trim());
                    cur = '';
                    continue;
                }
                cur += ch;
            }
            cells.push(cur.trim());
            return cells;
        });
    }

    function tableRowsToProducts(tableRows) {
        if (!tableRows || !tableRows.length) return [];
        const headerMap = {};
        tableRows[0].forEach((h, idx) => {
            headerMap[normalizeBulkHeader(h)] = idx;
        });

        const pick = (row, ...keys) => {
            for (const key of keys) {
                const idx = headerMap[key];
                if (idx !== undefined && row[idx] !== undefined && String(row[idx]).trim() !== '') {
                    return String(row[idx]).trim();
                }
            }
            return '';
        };

        const products = [];
        for (let r = 1; r < tableRows.length; r++) {
            const row = tableRows[r];
            if (!row || row.every(c => String(c || '').trim() === '')) continue;
            const productName = pick(row, 'productname', 'name');
            if (!productName) continue;
            products.push({
                category: pick(row, 'category'),
                brand: pick(row, 'brand'),
                productName: productName,
                productCode: pick(row, 'productcode', 'code'),
                unit: pick(row, 'unit', 'unitsize'),
                cost: pick(row, 'costprice', 'cost'),
                mrp: pick(row, 'mrp'),
                stock: pick(row, 'stock'),
                gst: pick(row, 'gst'),
                hsn: pick(row, 'hsn')
            });
        }
        return products;
    }

    function readBulkUploadFile(file) {
        return new Promise((resolve, reject) => {
            const ext = (file.name.split('.').pop() || '').toLowerCase();
            const reader = new FileReader();
            reader.onerror = () => reject(new Error('Could not read file.'));

            if (ext === 'csv') {
                reader.onload = e => {
                    try {
                        resolve(tableRowsToProducts(parseCsvText(e.target.result)));
                    } catch (err) {
                        reject(err);
                    }
                };
                reader.readAsText(file);
                return;
            }

            reader.onload = e => {
                try {
                    if (typeof XLSX === 'undefined') {
                        reject(new Error('Excel library not loaded. Please use CSV or refresh the page.'));
                        return;
                    }
                    const data = new Uint8Array(e.target.result);
                    const workbook = XLSX.read(data, { type: 'array' });
                    const sheet = workbook.Sheets[workbook.SheetNames[0]];
                    const rows = XLSX.utils.sheet_to_json(sheet, { header: 1, defval: '' });
                    resolve(tableRowsToProducts(rows));
                } catch (err) {
                    reject(err);
                }
            };
            reader.readAsArrayBuffer(file);
        });
    }

    async function uploadBulkProducts() {
        const fileInput = document.getElementById('bulkUploadFile');
        const file = fileInput.files[0];
        if (!file) {
            Swal.fire({ icon: 'warning', title: 'Select File', text: 'Please choose an Excel or CSV file.' });
            return;
        }

        const btn = document.getElementById('bulkUploadBtn');
        btn.disabled = true;
        btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span>Uploading...';

        try {
            const rows = await readBulkUploadFile(file);
            if (!rows.length) {
                Swal.fire({ icon: 'warning', title: 'No Data', text: 'No product rows found. Check headers and data rows.' });
                return;
            }

            const response = await fetch(contextPath + '/product/master/product/bulkUploadProducts.jsp', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json;charset=UTF-8' },
                body: JSON.stringify({ rows })
            });
            const result = await response.json();

            if (result.success) {
                let html = result.message;
                if (result.errors && result.errors.length) {
                    html += '<br><br><div style="text-align:left;max-height:180px;overflow:auto;font-size:13px;">';
                    result.errors.forEach(err => { html += err + '<br>'; });
                    html += '</div>';
                }
                Swal.fire({
                    icon: result.failed > 0 ? 'warning' : 'success',
                    title: result.failed > 0 ? 'Partial Import' : 'Import Complete',
                    html: html,
                    width: 520
                });
                if (result.imported > 0) {
                    fileInput.value = '';
                    loadProducts(1, currentSearch);
                }
            } else {
                Swal.fire({ icon: 'error', title: 'Upload Failed', text: result.message || 'Could not import products.' });
            }
        } catch (err) {
            Swal.fire({ icon: 'error', title: 'Error', text: err.message || 'Upload failed.' });
        } finally {
            btn.disabled = false;
            btn.innerHTML = '<i class="fas fa-upload me-1"></i>Upload Excel';
        }
    }
    </script>
</body>
</html>
