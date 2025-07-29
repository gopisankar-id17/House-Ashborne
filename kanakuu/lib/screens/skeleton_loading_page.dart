import 'package:flutter/material.dart';

// Base Skeleton Loading Widget for shared animation logic
abstract class BaseSkeletonLoadingState<T extends StatefulWidget> extends State<T> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> shimmerAnimation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );
    animationController.repeat();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Widget buildShimmerContainer({
    required double width,
    required double height,
    double borderRadius = 8,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment(-1.0 + shimmerAnimation.value, 0.0),
          end: Alignment(-0.5 + shimmerAnimation.value, 0.0),
          colors: [
            Color(0xFF2A2D3A),
            Color(0xFF3A3D4A),
            Color(0xFF2A2D3A),
          ],
          stops: [0.0, 0.2, 0.5],
        ),
      ),
    );
  }
}

// Analytics Page Skeleton Loading
class AnalyticsSkeletonPage extends StatefulWidget {
  @override
  _AnalyticsSkeletonPageState createState() => _AnalyticsSkeletonPageState();
}

class _AnalyticsSkeletonPageState extends BaseSkeletonLoadingState<AnalyticsSkeletonPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1D29),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: shimmerAnimation,
          builder: (context, child) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAnalyticsHeader(),
                  SizedBox(height: 20),
                  _buildPeriodSelector(),
                  SizedBox(height: 20),
                  _buildTabSelector(),
                  SizedBox(height: 20),
                  _buildFinancialHealthSkeleton(),
                  SizedBox(height: 20),
                  _buildStatsCardsSkeleton(),
                  SizedBox(height: 20),
                  _buildIncomeVsExpensesSkeleton(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnalyticsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildShimmerContainer(width: 120, height: 24),
            SizedBox(height: 8),
            buildShimmerContainer(width: 200, height: 14),
          ],
        ),
        Row(
          children: [
            buildShimmerContainer(width: 40, height: 40, borderRadius: 20),
            SizedBox(width: 12),
            buildShimmerContainer(width: 70, height: 32, borderRadius: 8),
          ],
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: List.generate(5, (index) => Padding(
        padding: EdgeInsets.only(right: 8),
        child: buildShimmerContainer(width: 40, height: 32, borderRadius: 8),
      )),
    );
  }

  Widget _buildTabSelector() {
    return Row(
      children: List.generate(4, (index) => Padding(
        padding: EdgeInsets.only(right: 20),
        child: buildShimmerContainer(width: 60, height: 32, borderRadius: 20),
      )),
    );
  }

  Widget _buildFinancialHealthSkeleton() {
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
              buildShimmerContainer(width: 140, height: 16),
              buildShimmerContainer(width: 50, height: 20, borderRadius: 6),
            ],
          ),
          SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                buildShimmerContainer(width: 80, height: 48),
                SizedBox(height: 8),
                buildShimmerContainer(width: 100, height: 14),
                SizedBox(height: 16),
                buildShimmerContainer(width: double.infinity, height: 8, borderRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCardsSkeleton() {
    return Row(
      children: [
        Expanded(child: _buildStatCard()),
        SizedBox(width: 16),
        Expanded(child: _buildStatCard()),
      ],
    );
  }

  Widget _buildStatCard() {
    return Container(
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
              buildShimmerContainer(width: 20, height: 20),
              SizedBox(width: 4),
              buildShimmerContainer(width: 80, height: 12),
            ],
          ),
          SizedBox(height: 8),
          buildShimmerContainer(width: 90, height: 20),
          SizedBox(height: 4),
          buildShimmerContainer(width: 70, height: 10),
        ],
      ),
    );
  }

  Widget _buildIncomeVsExpensesSkeleton() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF2A2D3A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildShimmerContainer(width: 160, height: 16),
          SizedBox(height: 20),
          buildShimmerContainer(width: double.infinity, height: 200, borderRadius: 8),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  buildShimmerContainer(width: 12, height: 2),
                  SizedBox(width: 6),
                  buildShimmerContainer(width: 50, height: 12),
                ],
              ),
              SizedBox(width: 20),
              Row(
                children: [
                  buildShimmerContainer(width: 12, height: 2),
                  SizedBox(width: 6),
                  buildShimmerContainer(width: 60, height: 12),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Transactions Page Skeleton Loading
class TransactionsSkeletonPage extends StatefulWidget {
  @override
  _TransactionsSkeletonPageState createState() => _TransactionsSkeletonPageState();
}

class _TransactionsSkeletonPageState extends BaseSkeletonLoadingState<TransactionsSkeletonPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1D29),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: shimmerAnimation,
          builder: (context, child) {
            return Column(
              children: [
                _buildTransactionsHeader(),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(20),
                    children: List.generate(8, (index) => _buildTransactionItemSkeleton()),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTransactionsHeader() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildShimmerContainer(width: 180, height: 24),
              SizedBox(height: 8),
              buildShimmerContainer(width: 220, height: 14),
            ],
          ),
          buildShimmerContainer(width: 70, height: 32, borderRadius: 8),
        ],
      ),
    );
  }

  Widget _buildTransactionItemSkeleton() {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF2A2D3A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          buildShimmerContainer(width: 48, height: 48, borderRadius: 12),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildShimmerContainer(width: 140, height: 16),
                SizedBox(height: 8),
                buildShimmerContainer(width: 80, height: 20, borderRadius: 6),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              buildShimmerContainer(width: 80, height: 16),
              SizedBox(height: 8),
              buildShimmerContainer(width: 60, height: 12),
            ],
          ),
        ],
      ),
    );
  }
}

// Settings Page Skeleton Loading
class SettingsSkeletonPage extends StatefulWidget {
  @override
  _SettingsSkeletonPageState createState() => _SettingsSkeletonPageState();
}

class _SettingsSkeletonPageState extends BaseSkeletonLoadingState<SettingsSkeletonPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A2E),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: shimmerAnimation,
          builder: (context, child) {
            return Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSettingsHeader(),
                  SizedBox(height: 32),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildSettingsSection(),
                        SizedBox(height: 24),
                        _buildSettingsSection(),
                        SizedBox(height: 24),
                        _buildSettingsSection(),
                        SizedBox(height: 24),
                        _buildSettingsSection(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSettingsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildShimmerContainer(width: 100, height: 24),
            SizedBox(height: 8),
            buildShimmerContainer(width: 160, height: 14),
          ],
        ),
        buildShimmerContainer(width: 36, height: 36, borderRadius: 8),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildShimmerContainer(width: 80, height: 16),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFF16213E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: List.generate(3, (index) => _buildSettingsItemSkeleton()),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItemSkeleton() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white10,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          buildShimmerContainer(width: 40, height: 40, borderRadius: 8),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildShimmerContainer(width: 100, height: 16),
                SizedBox(height: 4),
                buildShimmerContainer(width: 180, height: 12),
              ],
            ),
          ),
          buildShimmerContainer(width: 16, height: 16),
        ],
      ),
    );
  }
}

// Add Transaction Page Skeleton Loading
class AddTransactionSkeletonPage extends StatefulWidget {
  @override
  _AddTransactionSkeletonPageState createState() => _AddTransactionSkeletonPageState();
}

class _AddTransactionSkeletonPageState extends BaseSkeletonLoadingState<AddTransactionSkeletonPage> {

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Color(0xFF2A2D3A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: AnimatedBuilder(
        animation: shimmerAnimation,
        builder: (context, child) {
          return Column(
            children: [
              _buildAddTransactionHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTypeSelectorSkeleton(),
                      SizedBox(height: 24),
                      _buildAmountFieldSkeleton(),
                      SizedBox(height: 24),
                      _buildCategorySelectorSkeleton(),
                      SizedBox(height: 24),
                      _buildDescriptionFieldSkeleton(),
                      SizedBox(height: 24),
                      _buildDateFieldSkeleton(),
                      SizedBox(height: 32),
                      _buildActionButtonsSkeleton(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAddTransactionHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildShimmerContainer(width: 140, height: 20),
          buildShimmerContainer(width: 24, height: 24),
        ],
      ),
    );
  }

  Widget _buildTypeSelectorSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildShimmerContainer(width: 40, height: 16),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: buildShimmerContainer(width: double.infinity, height: 48, borderRadius: 8)),
            SizedBox(width: 12),
            Expanded(child: buildShimmerContainer(width: double.infinity, height: 48, borderRadius: 8)),
          ],
        ),
      ],
    );
  }

  Widget _buildAmountFieldSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildShimmerContainer(width: 60, height: 16),
        SizedBox(height: 12),
        buildShimmerContainer(width: double.infinity, height: 56, borderRadius: 8),
      ],
    );
  }

  Widget _buildCategorySelectorSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildShimmerContainer(width: 80, height: 16),
        SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return buildShimmerContainer(width: double.infinity, height: double.infinity, borderRadius: 8);
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionFieldSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildShimmerContainer(width: 90, height: 16),
        SizedBox(height: 12),
        buildShimmerContainer(width: double.infinity, height: 80, borderRadius: 8),
      ],
    );
  }

  Widget _buildDateFieldSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildShimmerContainer(width: 40, height: 16),
        SizedBox(height: 12),
        buildShimmerContainer(width: double.infinity, height: 56, borderRadius: 8),
      ],
    );
  }

  Widget _buildActionButtonsSkeleton() {
    return Row(
      children: [
        Expanded(child: buildShimmerContainer(width: double.infinity, height: 48, borderRadius: 8)),
        SizedBox(width: 16),
        Expanded(child: buildShimmerContainer(width: double.infinity, height: 48, borderRadius: 8)),
      ],
    );
  }
}