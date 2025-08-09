import 'package:flutter/material.dart';
import 'dart:math' as math;

// Pie Chart Painter for Spending Analysis
class PieChartPainter extends CustomPainter {
  final Map<String, double> categoryExpenses;
  final double totalExpenses;

  PieChartPainter(this.categoryExpenses, this.totalExpenses);

  @override
  void paint(Canvas canvas, Size size) {
    if (totalExpenses == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    double startAngle = -math.pi / 2;

    final paint = Paint()..style = PaintingStyle.fill;

    categoryExpenses.forEach((category, amount) {
      final sweepAngle = (amount / totalExpenses) * 2 * math.pi;
      
      paint.color = _getCategoryColorForPainter(category);
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      
      startAngle += sweepAngle;
    });
  }

  Color _getCategoryColorForPainter(String category) {
    switch (category.toLowerCase()) {
      case 'food': return Colors.orange;
      case 'transport': return Colors.brown;
      case 'bills': return Colors.red;
      case 'shopping': return Colors.pink;
      case 'fun': return Colors.purple;
      case 'health': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// Empty Pie Chart Painter
class EmptyPieChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.grey[700]!
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Expense Breakdown Pie Chart Painter (Donut style like in the screenshot)
class ExpenseBreakdownPieChart extends CustomPainter {
  final Map<String, double> categoryExpenses;
  final double totalExpenses;

  ExpenseBreakdownPieChart(this.categoryExpenses, this.totalExpenses);

  @override
  void paint(Canvas canvas, Size size) {
    if (totalExpenses == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.4; // Create donut hole
    double startAngle = -math.pi / 2;

    final paint = Paint()..style = PaintingStyle.fill;
    final separatorPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = 2;

    // Draw the donut segments
    categoryExpenses.forEach((category, amount) {
      final sweepAngle = (amount / totalExpenses) * 2 * math.pi;
      
      paint.color = _getExpenseBreakdownColor(category);
      
      // Create path for donut segment
      final path = Path();
      
      // Outer arc
      path.arcTo(
        Rect.fromCircle(center: center, radius: outerRadius),
        startAngle,
        sweepAngle,
        false,
      );
      
      // Inner arc (reverse direction)
      path.arcTo(
        Rect.fromCircle(center: center, radius: innerRadius),
        startAngle + sweepAngle,
        -sweepAngle,
        false,
      );
      
      path.close();
      canvas.drawPath(path, paint);
      
      startAngle += sweepAngle;
    });

    // Draw black separators between segments
    startAngle = -math.pi / 2;
    categoryExpenses.forEach((category, amount) {
      final sweepAngle = (amount / totalExpenses) * 2 * math.pi;
      
      // Draw separator line at the start of each segment
      final startX = center.dx + math.cos(startAngle) * innerRadius;
      final startY = center.dy + math.sin(startAngle) * innerRadius;
      final endX = center.dx + math.cos(startAngle) * outerRadius;
      final endY = center.dy + math.sin(startAngle) * outerRadius;
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        separatorPaint,
      );
      
      startAngle += sweepAngle;
    });

    // Draw black center circle to create the donut hole
    final centerPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Color(0xFF2A2D3A); // Match your background color

    canvas.drawCircle(center, innerRadius, centerPaint);

    // Draw black border around the center hole
    final centerBorderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = 2;

    canvas.drawCircle(center, innerRadius, centerBorderPaint);

    // Draw black border around the outer edge
    final outerBorderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = 2;

    canvas.drawCircle(center, outerRadius, outerBorderPaint);
  }

  Color _getExpenseBreakdownColor(String category) {
    switch (category.toLowerCase()) {
      case 'food & dining':
      case 'food':
        return Colors.orange;
      case 'transportation':
      case 'transport':
        return Colors.orange.shade800;
      case 'shopping':
        return Colors.orange.shade300;
      case 'bills & utilities':
      case 'bills':
        return Colors.purple;
      case 'entertainment':
      case 'fun':
        return Colors.green;
      case 'healthcare':
      case 'health':
        return Colors.purple.shade300;
      case 'education':
        return Colors.blue;
      case 'travel':
        return Colors.teal;
      case 'fitness':
        return Colors.lightGreen;
      case 'others':
      case 'other':
        return Colors.grey;
      default:
        // Generate colors for unknown categories
        final colors = [
          Colors.orange,
          Colors.orange.shade800,
          Colors.orange.shade300,
          Colors.purple,
          Colors.green,
          Colors.purple.shade300,
          Colors.blue,
          Colors.teal,
          Colors.lightGreen,
          Colors.grey,
        ];
        return colors[category.hashCode % colors.length];
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
