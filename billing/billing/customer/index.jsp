<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<%
long   totalCustomers = 0;
double totalDue       = 0;
double totalAdvance   = 0;
Vector dueList        = new Vector();
try {
    Vector tots = bill.getCustomerAccountTotals();
    if (tots != null && tots.size() >= 3) {
        totalCustomers = Long.parseLong(tots.get(0).toString());
        totalDue       = Double.parseDouble(tots.get(1).toString());
        totalAdvance   = Double.parseDouble(tots.get(2).toString());
    }
    dueList = bill.getCustomersDueList();
} catch(Exception _e) {}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Customers Balance</title>
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>
<jsp:include page="/assets/navbar/navbar.jsp" />
<%
    request.setAttribute("pageTitle",    "Customers Balance");
    request.setAttribute("pageSubtitle", "Credit Management — Customer Account");
    request.setAttribute("pageIcon",     "fa-solid fa-users");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

<div class="container mt-4 mst-page" style="max-width:680px;">

  <!-- Stat cards -->
  <div class="row g-3 mb-4">
    <div class="col-4">
      <div class="mst-card p-3 text-center">
        <div style="font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.8px;opacity:.7;">Due Customers</div>
        <div style="font-size:28px;font-weight:900;"><%=totalCustomers%></div>
      </div>
    </div>
    <div class="col-4">
      <div class="mst-card p-3 text-center" onclick="document.getElementById('dueModal').style.display='flex'" style="cursor:pointer;">
        <div style="font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.8px;opacity:.7;">Total Due</div>
        <div style="font-size:22px;font-weight:900;color:<%=totalDue > 0 ? "#dc2626" : "#16a34a"%>;">&#8377;<%=String.format("%,.2f", totalDue)%></div>
      </div>
    </div>
    <div class="col-4">
      <div class="mst-card p-3 text-center">
        <div style="font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.8px;opacity:.7;">Total Advance</div>
        <div style="font-size:22px;font-weight:900;color:#16a34a;">&#8377;<%=String.format("%,.2f", totalAdvance)%></div>
      </div>
    </div>
  </div>

  <!-- Search card -->
  <div class="mst-card">
    <div class="p-4">
            <h5 class="mb-4" style="font-weight:700;">
                <i class="fa-solid fa-magnifying-glass me-2"></i>Search Customer
            </h5>

            <div style="position:relative;">
                <input type="text" id="customerSearch" class="form-control fg-inp"
                       placeholder="Type name or phone number..." autocomplete="off"
                       style="font-size:15px;height:42px;padding-right:40px;">
                <i class="fa-solid fa-user" style="position:absolute;right:13px;top:50%;transform:translateY(-50%);opacity:.4;"></i>
                <ul id="customerDropdown" style="
                    display:none;position:absolute;top:100%;left:0;right:0;z-index:1000;
                    background:#fff;border:1.5px solid #d1d9e6;border-top:none;
                    border-radius:0 0 8px 8px;list-style:none;padding:0;margin:0;
                    max-height:260px;overflow-y:auto;box-shadow:0 4px 16px rgba(0,0,0,.10);
                "></ul>
            </div>

            <div id="selectedCustomerBox" style="display:none;margin-top:18px;
                border:1.5px solid #22c55e;border-radius:8px;padding:14px 16px;background:#f0fdf4;">
                <div style="display:flex;justify-content:space-between;align-items:center;">
                    <div>
                        <div style="font-weight:700;font-size:15px;" id="selName"></div>
                        <div style="font-size:13px;color:#555;margin-top:2px;" id="selPhone"></div>
                    </div>
                    <button class="btn btn-sm btn-success" onclick="goToView()">
                        View Account <i class="fa-solid fa-arrow-right ms-1"></i>
                    </button>
                </div>
            </div>
    </div>
  </div>
</div>

<script>
const contextPath = '<%=request.getContextPath()%>';
let selectedCustomerId = null;
let searchTimer = null;

const searchInput = document.getElementById('customerSearch');
const dropdown   = document.getElementById('customerDropdown');

searchInput.addEventListener('input', function() {
    const val = this.value.trim();
    clearTimeout(searchTimer);
    dropdown.style.display = 'none';
    document.getElementById('selectedCustomerBox').style.display = 'none';
    selectedCustomerId = null;

    if (val.length < 1) return;

    searchTimer = setTimeout(() => {
        // detect phone search if value is mostly digits
        const isPhone = /^\d+$/.test(val);
        const params  = isPhone ? 'phone=' + encodeURIComponent(val)
                                : 'query=' + encodeURIComponent(val);
        fetch(contextPath + '/billing/customerAutocomplete.jsp?' + params)
            .then(r => r.json())
            .then(data => renderDropdown(data))
            .catch(() => {});
    }, 280);
});

function renderDropdown(customers) {
    dropdown.innerHTML = '';
    if (!customers.length) {
        dropdown.innerHTML = '<li style="padding:10px 14px;color:#888;font-size:13px;">No customers found</li>';
        dropdown.style.display = 'block';
        return;
    }
    customers.forEach(c => {
        const li = document.createElement('li');
        li.style.cssText = 'padding:10px 14px;cursor:pointer;border-bottom:1px solid #f0f0f0;';
        li.innerHTML = '<span style="font-weight:600;">' + c.name + '</span>'
                     + '<span style="font-size:12px;color:#888;margin-left:8px;">' + (c.phone !== '-' ? c.phone : '') + '</span>';
        li.addEventListener('mouseenter', () => li.style.background = '#f1f5f9');
        li.addEventListener('mouseleave', () => li.style.background = '');
        li.addEventListener('click', () => selectCustomer(c));
        dropdown.appendChild(li);
    });
    dropdown.style.display = 'block';
}

function selectCustomer(c) {
    selectedCustomerId = c.id;
    searchInput.value  = c.name + (c.phone && c.phone !== '-' ? '  |  ' + c.phone : '');
    dropdown.style.display = 'none';
    document.getElementById('selName').textContent  = c.name;
    document.getElementById('selPhone').textContent = c.phone && c.phone !== '-' ? c.phone : '';
    document.getElementById('selectedCustomerBox').style.display = 'block';
}

function goToView() {
    if (!selectedCustomerId) return;
    window.location.href = contextPath + '/billing/customer/view.jsp?customerId=' + selectedCustomerId;
}

// Close dropdown on outside click
document.addEventListener('click', function(e) {
    if (!searchInput.contains(e.target) && !dropdown.contains(e.target)) {
        dropdown.style.display = 'none';
    }
});

// Enter key
searchInput.addEventListener('keydown', function(e) {
    if (e.key === 'Enter' && selectedCustomerId) goToView();
});
</script>

<!-- Due Customers Modal -->
<div id="dueModal" style="display:none;position:fixed;inset:0;z-index:2000;background:rgba(0,0,0,.45);align-items:center;justify-content:center;padding:16px;">
  <div style="background:#fff;border-radius:12px;width:100%;max-width:560px;max-height:85vh;display:flex;flex-direction:column;box-shadow:0 8px 40px rgba(0,0,0,.22);">

    <!-- Modal header -->
    <div style="display:flex;align-items:center;justify-content:space-between;padding:16px 20px;border-bottom:1px solid #e5e7eb;">
      <div>
        <div style="font-weight:800;font-size:15px;"><i class="fa-solid fa-triangle-exclamation me-2" style="color:#dc2626;"></i>Customers with Due</div>
        <div style="font-size:12px;opacity:.6;margin-top:2px;"><%=dueList.size()%> customer<%=dueList.size() != 1 ? "s" : ""%> &nbsp;|&nbsp; Total: &#8377;<%=String.format("%,.2f", totalDue)%></div>
      </div>
      <button onclick="document.getElementById('dueModal').style.display='none'" style="border:none;background:none;font-size:20px;cursor:pointer;opacity:.5;line-height:1;">&times;</button>
    </div>

    <!-- Modal body -->
    <div style="overflow-y:auto;flex:1;">
      <table style="width:100%;border-collapse:collapse;font-size:13px;">
        <thead>
          <tr style="background:#f8fafc;position:sticky;top:0;">
            <th style="padding:10px 16px;text-align:left;font-weight:700;font-size:11px;text-transform:uppercase;letter-spacing:.5px;">#</th>
            <th style="padding:10px 16px;text-align:left;font-weight:700;font-size:11px;text-transform:uppercase;letter-spacing:.5px;">Customer</th>
            <th style="padding:10px 16px;text-align:left;font-weight:700;font-size:11px;text-transform:uppercase;letter-spacing:.5px;">Phone</th>
            <th style="padding:10px 16px;text-align:right;font-weight:700;font-size:11px;text-transform:uppercase;letter-spacing:.5px;">Due</th>
          </tr>
        </thead>
        <tbody>
          <% if (dueList.isEmpty()) { %>
          <tr><td colspan="4" style="padding:24px;text-align:center;color:#888;">No customers with outstanding due.</td></tr>
          <%
          } else {
            for (int i = 0; i < dueList.size(); i++) {
              Vector dr = (Vector) dueList.get(i);
              String dCustId  = dr.get(0).toString();
              String dName    = dr.get(1).toString();
              String dPhone   = dr.get(2) != null ? dr.get(2).toString() : "-";
              double dBal     = 0; try { dBal = Double.parseDouble(dr.get(3).toString()); } catch(Exception ex){}
          %>
          <tr onclick="window.location.href='<%=request.getContextPath()%>/billing/customer/view.jsp?customerId=<%=dCustId%>'"
              style="cursor:pointer;border-bottom:1px solid #f0f0f0;background:#fff1f1;"
              onmouseover="this.style.background='#fee2e2'" onmouseout="this.style.background='#fff1f1'">
            <td style="padding:11px 16px;color:#888;"><%=i+1%></td>
            <td style="padding:11px 16px;font-weight:700;"><%=dName%></td>
            <td style="padding:11px 16px;color:#555;"><%=dPhone%></td>
            <td style="padding:11px 16px;text-align:right;font-weight:800;color:#dc2626;font-size:14px;">&#8377;<%=String.format("%,.2f", dBal)%></td>
          </tr>
          <% } } %>
        </tbody>
      </table>
    </div>

  </div>
</div>

</body>
</html>
