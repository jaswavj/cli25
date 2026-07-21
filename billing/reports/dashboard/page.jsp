<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<jsp:useBean id="op1" class="billing.billingBean" />
<jsp:useBean id="prod" class="product.productBean" />
<%
// ── Selected period from GET params (default = current month/year) ──────────
java.util.Calendar nowCal = java.util.Calendar.getInstance();
int curYear  = nowCal.get(java.util.Calendar.YEAR);
int curMonth = nowCal.get(java.util.Calendar.MONTH) + 1; // 1-based

String selYearParam  = request.getParameter("selYear");
String selMonthParam = request.getParameter("selMonth");
int selYear  = (selYearParam  != null && !selYearParam.isEmpty())  ? Integer.parseInt(selYearParam)  : curYear;
int selMonth = (selMonthParam != null && !selMonthParam.isEmpty()) ? Integer.parseInt(selMonthParam) : curMonth;
// clamp
if (selMonth < 1) selMonth = 1;
if (selMonth > 12) selMonth = 12;

// Selected month date range
java.util.Calendar selCal = java.util.Calendar.getInstance();
selCal.set(selYear, selMonth - 1, 1);
String selMonthStart = String.format("%04d-%02d-01", selYear, selMonth);
selCal.set(java.util.Calendar.DAY_OF_MONTH, selCal.getActualMaximum(java.util.Calendar.DAY_OF_MONTH));
String selMonthEnd = new java.text.SimpleDateFormat("yyyy-MM-dd").format(selCal.getTime());

// Previous month date range
java.util.Calendar prevCal = java.util.Calendar.getInstance();
prevCal.set(selYear, selMonth - 1, 1);
prevCal.add(java.util.Calendar.MONTH, -1);
prevCal.set(java.util.Calendar.DAY_OF_MONTH, 1);
String prevMonthStart = new java.text.SimpleDateFormat("yyyy-MM-dd").format(prevCal.getTime());
prevCal.set(java.util.Calendar.DAY_OF_MONTH, prevCal.getActualMaximum(java.util.Calendar.DAY_OF_MONTH));
String prevMonthEnd = new java.text.SimpleDateFormat("yyyy-MM-dd").format(prevCal.getTime());

// Display label for selected period
String[] MONTH_NAMES = {"","January","February","March","April","May","June","July","August","September","October","November","December"};
String selPeriodLabel = MONTH_NAMES[selMonth] + " " + selYear;

///////////////////  Sales  /////////////////
double thisSale  = op1.getTotalSalesByDateRange(selMonthStart, selMonthEnd);
double lastSale  = op1.getTotalSalesByDateRange(prevMonthStart, prevMonthEnd);
double saleMarginPercent = lastSale != 0 ? ((thisSale - lastSale) / lastSale) * 100 : 0;

//////////////////  Purchase  /////////////////
double thisPurchase  = op1.getTotalPurchasesByDateRange(selMonthStart, selMonthEnd);
double lastPurchase  = op1.getTotalPurchasesByDateRange(prevMonthStart, prevMonthEnd);
double purchaseMarginPercent = lastPurchase != 0 ? ((thisPurchase - lastPurchase) / lastPurchase) * 100 : 0;

///////////////////  Today's Sales (kept for potential use)  /////////////////
double todaySales    = op1.getTodaySales();
int    todayBillCount = op1.getTodayBillCount();

///////////////////  Profit  /////////////////
Vector thisMonthProfitData = op1.getProfitAnalysisReport(selMonthStart, selMonthEnd);
double thisProfit = 0.0;
for (int i = 0; i < thisMonthProfitData.size(); i++) {
    Vector row = (Vector) thisMonthProfitData.elementAt(i);
    double totalCost = Double.parseDouble(row.elementAt(4).toString());
    double saleTotal = Double.parseDouble(row.elementAt(5).toString());
    if (totalCost > 0) thisProfit += (saleTotal - totalCost);
}

Vector lastMonthProfitData = op1.getProfitAnalysisReport(prevMonthStart, prevMonthEnd);
double lastProfit = 0.0;
for (int i = 0; i < lastMonthProfitData.size(); i++) {
    Vector row = (Vector) lastMonthProfitData.elementAt(i);
    double totalCost = Double.parseDouble(row.elementAt(4).toString());
    double saleTotal = Double.parseDouble(row.elementAt(5).toString());
    if (totalCost > 0) lastProfit += (saleTotal - totalCost);
}

double profitMarginPercent = lastProfit != 0 ? ((thisProfit - lastProfit) / lastProfit) * 100 : 0;

///////////////////  Expenses  /////////////////
double thisExpense = 0.0;
try {
    Vector thisMonthExpenses = prod.getExpenseReport(selMonthStart, selMonthEnd, 0);
    if (thisMonthExpenses != null) {
        for (int i = 0; i < thisMonthExpenses.size(); i++) {
            Vector row = (Vector) thisMonthExpenses.get(i);
            if (row.size() > 4) thisExpense += Double.parseDouble(row.get(4).toString());
        }
    }
} catch (Exception e) { System.err.println("Error loading expenses: " + e.getMessage()); }

double lastExpense = 0.0;
try {
    Vector lastMonthExpenses = prod.getExpenseReport(prevMonthStart, prevMonthEnd, 0);
    if (lastMonthExpenses != null) {
        for (int i = 0; i < lastMonthExpenses.size(); i++) {
            Vector row = (Vector) lastMonthExpenses.get(i);
            if (row.size() > 4) lastExpense += Double.parseDouble(row.get(4).toString());
        }
    }
} catch (Exception e) { System.err.println("Error loading last expenses: " + e.getMessage()); }

double expenseMarginPercent = lastExpense != 0 ? ((thisExpense - lastExpense) / lastExpense) * 100 : 0;

double netProfit = thisSale - thisPurchase - thisExpense;

// Get today's date label
java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd-MMM-yyyy");
String todayDate = sdf.format(new java.util.Date());

/////////////////////  Chart Data — selected month daily breakdown  //////////////////
Vector vec = op1.getDailySalesForMonth(selYear, selMonth);
StringBuilder labels      = new StringBuilder();
StringBuilder salesData   = new StringBuilder();
for (int i = 0; i < vec.size(); i++) {
    Vector row  = (Vector) vec.elementAt(i);
    labels.append("\"").append(row.elementAt(0)).append("\"");
    salesData.append(row.elementAt(1).toString().isEmpty() ? "0" : row.elementAt(1));
    if (i < vec.size() - 1) { labels.append(", "); salesData.append(", "); }
}

Vector vecPurchase = op1.getDailyPurchaseForMonth(selYear, selMonth);
StringBuilder purchaseData = new StringBuilder();
for (int i = 0; i < vecPurchase.size(); i++) {
    Vector row = (Vector) vecPurchase.elementAt(i);
    purchaseData.append(row.elementAt(1).toString().isEmpty() ? "0" : row.elementAt(1));
    if (i < vecPurchase.size() - 1) purchaseData.append(", ");
}

// Build year options (current year back 5 years, forward 1 year)
int yearMin = curYear - 4;
int yearMax = curYear + 1;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Executive Dashboard</title>
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        .dashboard-card {
            border: none;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(15,27,53,0.07);
            transition: transform 0.2s, box-shadow 0.2s;
            overflow: hidden;
            background: var(--bill-card);
        }
        .dashboard-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 6px 20px rgba(15,27,53,0.13);
        }
        .card-icon {
            position: absolute;
            right: 16px;
            top: 50%;
            transform: translateY(-50%);
            font-size: 2.5rem;
            opacity: 0.12;
        }
        .trend-up   { color: var(--bill-green); font-size: 0.9rem; font-weight: 600; }
        .trend-down { color: var(--bill-red);   font-size: 0.9rem; font-weight: 600; }
        .period-filter select.fg-inp { padding: 0.3rem 0.6rem; font-size: 0.85rem; }
        .period-filter .bb { padding: 0.32rem 0.9rem; font-size: 0.85rem; }
        .chart-container {
            background: var(--bill-card);
            border-radius: 12px;
            padding: 18px 20px;
            border: 1px solid var(--bill-border);
            box-shadow: 0 2px 8px rgba(15,27,53,0.05);
            height: 100%;
        }
        .chart-container h5 { color: var(--bill-navy); font-size: 0.92rem; margin-bottom: 0; }
        .chart-wrapper    { position: relative; height: 260px; width: 100%; }
        .chart-wrapper-sm { position: relative; height: 200px; width: 100%; }
        .dash-badge { display:inline-block; padding:2px 10px; border-radius:20px; font-size:0.78rem; font-weight:600; color:#fff; background: var(--bill-navy); }
    </style>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>
<%
    request.setAttribute("pageTitle",    "Dashboard");
    request.setAttribute("pageSubtitle", "Business Overview — " + selPeriodLabel);
    request.setAttribute("pageIcon",     "fa-solid fa-gauge-high");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

    <div class="container-fluid mt-3 mst-page">

        <!-- Period Filter Bar -->
        <form method="get" id="periodForm" class="d-flex align-items-center gap-3 mb-4 p-3 mst-card" style="flex-wrap:wrap;">
            <span class="fw-semibold" style="color:var(--bill-navy);"><i class="fa-solid fa-calendar-days me-2"></i>Select Period</span>
            <div class="d-flex align-items-center gap-2">
                <label class="fw-semibold" style="font-size:0.85rem;">Year</label>
                <select name="selYear" class="form-select fg-inp" style="width:100px;" onchange="document.getElementById('periodForm').submit()">
                    <% for (int y = yearMax; y >= yearMin; y--) { %>
                    <option value="<%= y %>" <%= (y == selYear ? "selected" : "") %>><%= y %></option>
                    <% } %>
                </select>
            </div>
            <div class="d-flex align-items-center gap-2">
                <label class="fw-semibold" style="font-size:0.85rem;">Month</label>
                <select name="selMonth" class="form-select fg-inp" style="width:130px;" onchange="document.getElementById('periodForm').submit()">
                    <% for (int m = 1; m <= 12; m++) { %>
                    <option value="<%= m %>" <%= (m == selMonth ? "selected" : "") %>><%= MONTH_NAMES[m] %></option>
                    <% } %>
                </select>
            </div>
            <button type="submit" class="bb bb-primary"><i class="fa-solid fa-rotate me-1"></i>Load</button>
            <% if (selYear != curYear || selMonth != curMonth) { %>
            <a href="page.jsp" class="bb bb-outline"><i class="fa-solid fa-house me-1"></i>Current Month</a>
            <% } %>
            <span class="ms-auto text-muted" style="font-size:0.82rem;">Showing data for <strong style="color:var(--bill-navy);"><%= selPeriodLabel %></strong></span>
        </form>

        <!-- 4 Summary Cards -->
        <div class="row g-3 mb-4">

          <!-- Sales -->
          <div class="col-lg-3 col-sm-6">
            <div style="border-radius:16px;overflow:hidden;box-shadow:0 4px 20px rgba(59,130,246,.18);background:linear-gradient(135deg,#1e40af 0%,#3b82f6 100%);color:#fff;padding:22px 22px 16px;position:relative;min-height:140px;">
              <div style="position:absolute;right:-12px;top:-12px;width:90px;height:90px;background:rgba(255,255,255,.08);border-radius:50%;"></div>
              <div style="position:absolute;right:16px;top:16px;font-size:2rem;opacity:.25;"><i class="fa-solid fa-chart-line"></i></div>
              <div style="font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:1.2px;opacity:.8;margin-bottom:8px;">Total Sales</div>
              <div style="font-size:28px;font-weight:900;letter-spacing:-.5px;margin-bottom:10px;">&#8377;<%= String.format("%,.2f", thisSale) %></div>
              <div style="font-size:11px;background:rgba(255,255,255,.15);border-radius:20px;display:inline-flex;align-items:center;gap:5px;padding:3px 10px;">
                <% if (lastSale == 0) { %>
                  <span style="opacity:.8;">— No prev. data</span>
                <% } else if (saleMarginPercent >= 0) { %>
                  <i class="fa-solid fa-arrow-trend-up"></i><span><%= String.format("%.1f", saleMarginPercent) %>% vs last month</span>
                <% } else { %>
                  <i class="fa-solid fa-arrow-trend-down"></i><span><%= String.format("%.1f", Math.abs(saleMarginPercent)) %>% vs last month</span>
                <% } %>
              </div>
            </div>
          </div>

          <!-- Purchase -->
          <div class="col-lg-3 col-sm-6">
            <div style="border-radius:16px;overflow:hidden;box-shadow:0 4px 20px rgba(234,88,12,.18);background:linear-gradient(135deg,#c2410c 0%,#f97316 100%);color:#fff;padding:22px 22px 16px;position:relative;min-height:140px;">
              <div style="position:absolute;right:-12px;top:-12px;width:90px;height:90px;background:rgba(255,255,255,.08);border-radius:50%;"></div>
              <div style="position:absolute;right:16px;top:16px;font-size:2rem;opacity:.25;"><i class="fa-solid fa-cart-shopping"></i></div>
              <div style="font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:1.2px;opacity:.8;margin-bottom:8px;">Total Purchase</div>
              <div style="font-size:28px;font-weight:900;letter-spacing:-.5px;margin-bottom:10px;">&#8377;<%= String.format("%,.2f", thisPurchase) %></div>
              <div style="font-size:11px;background:rgba(255,255,255,.15);border-radius:20px;display:inline-flex;align-items:center;gap:5px;padding:3px 10px;">
                <% if (lastPurchase == 0) { %>
                  <span style="opacity:.8;">— No prev. data</span>
                <% } else if (purchaseMarginPercent >= 0) { %>
                  <i class="fa-solid fa-arrow-trend-up"></i><span><%= String.format("%.1f", purchaseMarginPercent) %>% vs last month</span>
                <% } else { %>
                  <i class="fa-solid fa-arrow-trend-down"></i><span><%= String.format("%.1f", Math.abs(purchaseMarginPercent)) %>% vs last month</span>
                <% } %>
              </div>
            </div>
          </div>

          <!-- Expense -->
          <div class="col-lg-3 col-sm-6">
            <div style="border-radius:16px;overflow:hidden;box-shadow:0 4px 20px rgba(124,58,237,.18);background:linear-gradient(135deg,#6d28d9 0%,#a78bfa 100%);color:#fff;padding:22px 22px 16px;position:relative;min-height:140px;">
              <div style="position:absolute;right:-12px;top:-12px;width:90px;height:90px;background:rgba(255,255,255,.08);border-radius:50%;"></div>
              <div style="position:absolute;right:16px;top:16px;font-size:2rem;opacity:.25;"><i class="fa-solid fa-receipt"></i></div>
              <div style="font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:1.2px;opacity:.8;margin-bottom:8px;">Total Expense</div>
              <div style="font-size:28px;font-weight:900;letter-spacing:-.5px;margin-bottom:10px;">&#8377;<%= String.format("%,.2f", thisExpense) %></div>
              <div style="font-size:11px;background:rgba(255,255,255,.15);border-radius:20px;display:inline-flex;align-items:center;gap:5px;padding:3px 10px;">
                <% if (lastExpense == 0) { %>
                  <span style="opacity:.8;">— No prev. data</span>
                <% } else if (expenseMarginPercent >= 0) { %>
                  <i class="fa-solid fa-arrow-trend-up"></i><span><%= String.format("%.1f", expenseMarginPercent) %>% vs last month</span>
                <% } else { %>
                  <i class="fa-solid fa-arrow-trend-down"></i><span><%= String.format("%.1f", Math.abs(expenseMarginPercent)) %>% vs last month</span>
                <% } %>
              </div>
            </div>
          </div>

          <!-- Net Profit -->
          <div class="col-lg-3 col-sm-6">
            <% String profitGrad = netProfit >= 0 ? "linear-gradient(135deg,#065f46 0%,#10b981 100%)" : "linear-gradient(135deg,#991b1b 0%,#ef4444 100%)"; %>
            <div style="border-radius:16px;overflow:hidden;box-shadow:0 4px 20px rgba(16,185,129,.18);background:<%= profitGrad %>;color:#fff;padding:22px 22px 16px;position:relative;min-height:140px;">
              <div style="position:absolute;right:-12px;top:-12px;width:90px;height:90px;background:rgba(255,255,255,.08);border-radius:50%;"></div>
              <div style="position:absolute;right:16px;top:16px;font-size:2rem;opacity:.25;"><i class="fa-solid fa-coins"></i></div>
              <div style="font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:1.2px;opacity:.8;margin-bottom:8px;">Net Profit</div>
              <div style="font-size:28px;font-weight:900;letter-spacing:-.5px;margin-bottom:10px;">&#8377;<%= String.format("%,.2f", netProfit) %></div>
              <div style="font-size:11px;background:rgba(255,255,255,.15);border-radius:20px;display:inline-flex;align-items:center;gap:5px;padding:3px 10px;">
                <% if (lastProfit == 0) { %>
                  <span style="opacity:.8;">— No prev. data</span>
                <% } else if (profitMarginPercent >= 0) { %>
                  <i class="fa-solid fa-arrow-trend-up"></i><span><%= String.format("%.1f", profitMarginPercent) %>% vs last month</span>
                <% } else { %>
                  <i class="fa-solid fa-arrow-trend-down"></i><span><%= String.format("%.1f", Math.abs(profitMarginPercent)) %>% vs last month</span>
                <% } %>
              </div>
            </div>
          </div>

        </div>

        <!-- Charts Section -->
        <div class="row g-4">
            <!-- Main Combined Chart -->
            <div class="col-lg-8">
                <div class="chart-container">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="fw-bold">Financial Overview <small class="text-muted fw-normal" style="font-size:0.8rem;">(<%= selPeriodLabel %> — Daily)</small></h5>
                        <span class="dash-badge"><i class="fa-solid fa-calendar-days me-1"></i>Daily</span>
                    </div>
                    <div class="chart-wrapper">
                        <canvas id="combinedChart"></canvas>
                    </div>
                </div>
            </div>

            <!-- Distribution / Pie Chart (Placeholder or derived data) -->
            <!-- Since we don't have category data here, let's use the Purchase vs Sales comparison bar chart -->
            <div class="col-lg-4">
                <div class="chart-container">
                    <h5 class="fw-bold mb-3">Sales vs Purchase <small class="text-muted">(<%= selPeriodLabel %>)</small></h5>
                    <div class="chart-wrapper">
                        <canvas id="comparisonChart"></canvas>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Detailed Graphs Row -->
        <div class="row g-4 mt-1">
             <div class="col-md-6">
                <div class="chart-container">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="fw-bold">Sales Trend</h5>
                        <button id="downloadMargin" class="bb bb-outline" style="padding:3px 12px;font-size:0.8rem;"><i class="fa-solid fa-download"></i> Save</button>
                    </div>
                    <div class="chart-wrapper-sm">
                        <canvas id="marginChart"></canvas>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="chart-container">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="fw-bold">Purchase Trend</h5>
                        <button id="downloadPurchase" class="bb bb-outline" style="padding:3px 12px;font-size:0.8rem;"><i class="fa-solid fa-download"></i> Save</button>
                    </div>
                    <div class="chart-wrapper-sm">
                        <canvas id="purchaseChart"></canvas>
                    </div>
                </div>
            </div>
        </div>

    </div>

    <script>
        // Data from Server — selected period: <%= selPeriodLabel %>
        const labels       = [<%= labels.toString() %>];
        const salesData    = [<%= salesData.toString() %>];
        const purchaseData = [<%= purchaseData.toString() %>];

        // Totals for doughnut
        const totalSalesMonth    = <%= thisSale %>;
        const totalPurchaseMonth = <%= thisPurchase %>;

        // Helper: gradient fill
        function makeGradient(ctx, top, bottom) {
            const grad = ctx.createLinearGradient(0, 0, 0, 300);
            grad.addColorStop(0, top);
            grad.addColorStop(1, bottom);
            return grad;
        }

        // Common Chart Options
        const commonOptions = {
            responsive: true,
            maintainAspectRatio: false,
            animation: { duration: 800, easing: 'easeInOutQuart' },
            plugins: {
                legend: {
                    position: 'top',
                    labels: { color: '#0f172a', font: { size: 12, weight: '600' }, boxWidth: 12, padding: 16 }
                },
                tooltip: {
                    mode: 'index',
                    intersect: false,
                    backgroundColor: 'rgba(15,27,53,0.92)',
                    titleColor: '#c9a227',
                    bodyColor: '#e2e8f0',
                    padding: 12,
                    cornerRadius: 8,
                    callbacks: {
                        label: function(ctx) {
                            return ' ₹' + parseFloat(ctx.parsed.y).toLocaleString('en-IN', {minimumFractionDigits: 2, maximumFractionDigits: 2});
                        }
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    grid: { color: 'rgba(209,217,230,0.5)', drawBorder: false },
                    ticks: { color: '#64748b', callback: function(v) { return '₹' + v.toLocaleString('en-IN'); } }
                },
                x: {
                    grid: { display: false },
                    ticks: { color: '#64748b' }
                }
            },
            interaction: { mode: 'nearest', axis: 'x', intersect: false }
        };

        // 1. Combined Chart — area + bar with gradient fill
        const combinedCtx = document.getElementById('combinedChart').getContext('2d');
        new Chart(combinedCtx, {
            data: {
                labels: labels,
                datasets: [
                    {
                        type: 'line',
                        label: 'Sales',
                        data: salesData,
                        borderColor: '#c9a227',
                        backgroundColor: makeGradient(combinedCtx, 'rgba(201,162,39,0.35)', 'rgba(201,162,39,0.01)'),
                        borderWidth: 2.5,
                        fill: true,
                        tension: 0.42,
                        pointRadius: 4,
                        pointBackgroundColor: '#c9a227',
                        pointBorderColor: '#fff',
                        pointBorderWidth: 1.5,
                        pointHoverRadius: 7,
                        order: 1
                    },
                    {
                        type: 'bar',
                        label: 'Purchase',
                        data: purchaseData,
                        backgroundColor: 'rgba(26,37,64,0.70)',
                        borderColor: '#1a2540',
                        borderWidth: 0,
                        borderRadius: 5,
                        barPercentage: 0.5,
                        order: 2
                    }
                ]
            },
            options: {
                ...commonOptions,
                plugins: {
                    ...commonOptions.plugins,
                    annotation: {},
                    title: { display: false }
                }
            }
        });

        // 2. Comparison Chart — doughnut with net-profit arc
        new Chart(document.getElementById('comparisonChart'), {
            type: 'doughnut',
            data: {
                labels: ['Total Sales', 'Total Purchase', 'Net Profit'],
                datasets: [{
                    data: [
                        totalSalesMonth,
                        totalPurchaseMonth,
                        Math.max(0, totalSalesMonth - totalPurchaseMonth)
                    ],
                    backgroundColor: ['#c9a227', '#1a2540', '#059669'],
                    borderColor: ['#c9a227', '#1a2540', '#059669'],
                    borderWidth: 2,
                    hoverOffset: 12
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                animation: { animateRotate: true, duration: 900 },
                plugins: {
                    legend: { position: 'bottom', labels: { color: '#0f172a', font: { size: 11 }, padding: 12, boxWidth: 12 } },
                    tooltip: {
                        backgroundColor: 'rgba(15,27,53,0.92)',
                        titleColor: '#c9a227',
                        bodyColor: '#e2e8f0',
                        callbacks: {
                            label: function(ctx) {
                                const total = ctx.dataset.data.reduce((a,b)=>a+b,0);
                                const pct   = total > 0 ? ((ctx.parsed / total)*100).toFixed(1) : 0;
                                return ' ₹' + ctx.parsed.toLocaleString('en-IN',{minimumFractionDigits:2,maximumFractionDigits:2}) + '  (' + pct + '%)';
                            }
                        }
                    }
                },
                cutout: '65%'
            }
        });

        // 3. Detailed Sales Chart — gradient bar
        const marginCtx = document.getElementById('marginChart').getContext('2d');
        const marginChart = new Chart(marginCtx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Daily Sales',
                    data: salesData,
                    backgroundColor: makeGradient(marginCtx, 'rgba(201,162,39,0.9)', 'rgba(201,162,39,0.4)'),
                    borderColor: '#c9a227',
                    borderWidth: 0,
                    borderRadius: 6,
                    borderSkipped: false,
                    barPercentage: 0.65
                }]
            },
            options: {
                ...commonOptions,
                plugins: {
                    ...commonOptions.plugins,
                    legend: { display: false }
                }
            }
        });

        // 4. Detailed Purchase Chart — gradient bar
        const purchaseCtx = document.getElementById('purchaseChart').getContext('2d');
        const purchaseChart = new Chart(purchaseCtx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Daily Purchase',
                    data: purchaseData,
                    backgroundColor: makeGradient(purchaseCtx, 'rgba(26,37,64,0.88)', 'rgba(26,37,64,0.35)'),
                    borderColor: '#1a2540',
                    borderWidth: 0,
                    borderRadius: 6,
                    borderSkipped: false,
                    barPercentage: 0.65
                }]
            },
            options: {
                ...commonOptions,
                plugins: {
                    ...commonOptions.plugins,
                    legend: { display: false }
                }
            }
        });

        // Download Handlers
        document.getElementById('downloadMargin').addEventListener('click', function() {
            const link = document.createElement('a');
            link.download = 'sales_<%= selYear %>_<%= selMonth %>.png';
            link.href = marginChart.toBase64Image();
            link.click();
        });

        document.getElementById('downloadPurchase').addEventListener('click', function() {
            const link = document.createElement('a');
            link.download = 'purchase_<%= selYear %>_<%= selMonth %>.png';
            link.href = purchaseChart.toBase64Image();
            link.click();
        });
    </script>
</body>
</html>
