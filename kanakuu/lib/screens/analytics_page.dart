import 'package:flutter/material.dart';
import 'skeleton_loading_page.dart';

class AnalyticsPage extends StatefulWidget {
  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate data loading
    Future.delayed(Duration(seconds: 3), () {
      setState(() => isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading 
      ? AnalyticsSkeletonPage()
      : ActualAnalyticsPage(); // Your existing analytics page content
  }
}

class ActualAnalyticsPage extends StatefulWidget {
  @override
  _ActualAnalyticsPageState createState() => _ActualAnalyticsPageState(); // Fixed: Changed to _ActualAnalyticsPageState
}

class _ActualAnalyticsPageState extends State<ActualAnalyticsPage> { // Fixed: Changed from _AnalyticsPageState to _ActualAnalyticsPageState
  String selectedPeriod = '1M';
  String selectedTab = 'Overview';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1D29),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 20),
              _buildPeriodSelector(),
              SizedBox(height: 20),
              _buildTabSelector(),
              SizedBox(height: 20),
              _buildFinancialHealth(),
              SizedBox(height: 20),
              _buildStatsCards(),
              SizedBox(height: 20),
              _buildIncomeVsExpenses(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analytics',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Insights into your financial patterns',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Color(0xFF2A2D3A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.file_download_outlined,
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Export',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    List<String> periods = ['1W', '1M', '6M', '1Y', 'ALL'];
    
    return Row(
      children: periods.map((period) {
        bool isSelected = selectedPeriod == period;
        return GestureDetector(
          onTap: () => setState(() => selectedPeriod = period),
          child: Container(
            margin: EdgeInsets.only(right: 8),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.orange : Color(0xFF2A2D3A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              period,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTabSelector() {
    List<Map<String, dynamic>> tabs = [
      {'name': 'Overview', 'icon': Icons.dashboard_outlined},
      {'name': 'Spending', 'icon': Icons.trending_down},
      {'name': 'Categories', 'icon': Icons.pie_chart_outline},
      {'name': 'Goals', 'icon': Icons.flag_outlined},
    ];

    return Row(
      children: tabs.map((tab) {
        bool isSelected = selectedTab == tab['name'];
        return GestureDetector(
          onTap: () => setState(() => selectedTab = tab['name']),
          child: Container(
            margin: EdgeInsets.only(right: 20),
            padding: EdgeInsets.symmetric(
              horizontal: isSelected ? 12 : 0, 
              vertical: isSelected ? 8 : 0
            ),
            decoration: BoxDecoration(
              color: isSelected ? Colors.orange : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  tab['icon'],
                  color: isSelected ? Colors.black : Colors.grey[400],
                  size: 16,
                ),
                if (isSelected) ...[
                  SizedBox(width: 6),
                  Text(
                    tab['name'],
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFinancialHealth() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF2A2D3A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Financial Health',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Good',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Text(
                  '75',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Health Score',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    widthFactor: 0.75,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange, Colors.green],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF2A2D3A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      color: Colors.orange,
                      size: 20,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Total Spending',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '\$19,900',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'This period',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF2A2D3A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: Colors.green,
                      size: 20,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Savings Rate',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '36.2%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '+2.1% vs last period',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIncomeVsExpenses() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF2A2D3A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Income vs Expenses',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 20),
          Container(
            height: 200,
            child: CustomPaint(
              size: Size(double.infinity, 200),
              painter: IncomeExpenseChartPainter(),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 2,
                    color: Colors.green,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Income',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 20),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 2,
                    color: Colors.orange,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Spending',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class IncomeExpenseChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeWidth = 2..style = PaintingStyle.stroke;

    // Chart background
    final backgroundPaint = Paint()..color = Color(0xFF1A1D29);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // Y-axis labels and grid lines
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );

    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..strokeWidth = 1;

    List<int> yValues = [0, 1500, 3000, 4500, 6000];
    for (int i = 0; i < yValues.length; i++) {
      double y = size.height - (i * size.height / (yValues.length - 1));
      
      // Draw grid line
      canvas.drawLine(
        Offset(40, y),
        Offset(size.width, y),
        gridPaint,
      );

      // Draw Y-axis label
      textPainter.text = TextSpan(
        text: yValues[i].toString(),
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, y - 6));
    }

    // X-axis labels
    List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    double xStep = (size.width - 40) / (months.length - 1);
    
    for (int i = 0; i < months.length; i++) {
      double x = 40 + (i * xStep);
      textPainter.text = TextSpan(
        text: months[i],
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - 10, size.height + 5));
    }

    // Sample data points for income (green line)
    List<double> incomeData = [4000, 4200, 3800, 4500, 4800, 5000];
    List<double> expenseData = [2800, 3200, 2900, 3400, 3600, 3900];

    // Draw income area (green)
    paint.color = Colors.green;
    Path incomePath = Path();
    List<Offset> incomePoints = [];
    
    for (int i = 0; i < incomeData.length; i++) {
      double x = 40 + (i * xStep);
      double y = size.height - (incomeData[i] / 6000 * size.height);
      incomePoints.add(Offset(x, y));
      
      if (i == 0) {
        incomePath.moveTo(x, y);
      } else {
        incomePath.lineTo(x, y);
      }
    }

    // Fill area under income curve
    Path incomeAreaPath = Path.from(incomePath);
    incomeAreaPath.lineTo(40 + ((incomeData.length - 1) * xStep), size.height);
    incomeAreaPath.lineTo(40, size.height);
    incomeAreaPath.close();
    
    Paint incomeAreaPaint = Paint()
      ..color = Colors.green.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawPath(incomeAreaPath, incomeAreaPaint);
    canvas.drawPath(incomePath, paint);

    // Draw expense area (orange)
    paint.color = Colors.orange;
    Path expensePath = Path();
    
    for (int i = 0; i < expenseData.length; i++) {
      double x = 40 + (i * xStep);
      double y = size.height - (expenseData[i] / 6000 * size.height);
      
      if (i == 0) {
        expensePath.moveTo(x, y);
      } else {
        expensePath.lineTo(x, y);
      }
    }

    // Fill area under expense curve
    Path expenseAreaPath = Path.from(expensePath);
    expenseAreaPath.lineTo(40 + ((expenseData.length - 1) * xStep), size.height);
    expenseAreaPath.lineTo(40, size.height);
    expenseAreaPath.close();
    
    Paint expenseAreaPaint = Paint()
      ..color = Colors.orange.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawPath(expenseAreaPath, expenseAreaPaint);
    canvas.drawPath(expensePath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}