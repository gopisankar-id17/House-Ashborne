import 'package:flutter/material.dart';
import '../services/category_service.dart';

class CategoryManagementPage extends StatefulWidget {
  @override
  _CategoryManagementPageState createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage> with SingleTickerProviderStateMixin {
  final CategoryService _categoryService = CategoryService();
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeCategoriesIfNeeded();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeCategoriesIfNeeded() async {
    final areInitialized = await _categoryService.areCategoriesInitialized();
    if (!areInitialized) {
      await _categoryService.initializeDefaultCategories();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF16213E),
      appBar: AppBar(
        backgroundColor: Color(0xFF16213E),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Category Management',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Color(0xFFFF6B35),
          labelColor: Color(0xFFFF6B35),
          unselectedLabelColor: Colors.grey[400],
          tabs: [
            Tab(text: 'Expense Categories'),
            Tab(text: 'Income Categories'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryList('expense'),
          _buildCategoryList('income'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFFF6B35),
        onPressed: () => _showAddCategoryDialog(),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCategoryList(String type) {
    return StreamBuilder<List<CategoryModel>>(
      stream: _categoryService.getCategoriesStream(type: type),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(type);
        }

        final categories = snapshot.data!;
        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _buildCategoryCard(category);
          },
        );
      },
    );
  }

  Widget _buildCategoryCard(CategoryModel category) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Color(0xFF1E2749),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: category.color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            category.icon,
            color: category.color,
            size: 24,
          ),
        ),
        title: Text(
          category.name,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          category.type.toUpperCase(),
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.grey[400]),
          color: Color(0xFF1E2749),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditCategoryDialog(category);
                break;
              case 'delete':
                _showDeleteConfirmation(category);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('Edit', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        color: Color(0xFFFF6B35),
      ),
    );
  }

  Widget _buildEmptyState(String type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            type == 'expense' ? Icons.money_off : Icons.attach_money,
            size: 64,
            color: Colors.grey[600],
          ),
          SizedBox(height: 16),
          Text(
            'No ${type} categories yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap the + button to add your first ${type} category',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog() {
    final currentType = _tabController.index == 0 ? 'expense' : 'income';
    _showCategoryDialog(type: currentType);
  }

  void _showEditCategoryDialog(CategoryModel category) {
    _showCategoryDialog(category: category, type: category.type);
  }

  void _showCategoryDialog({CategoryModel? category, required String type}) {
    final isEditing = category != null;
    final nameController = TextEditingController(text: category?.name ?? '');
    IconData selectedIcon = category?.icon ?? Icons.category;
    Color selectedColor = category?.color ?? Colors.blue;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Color(0xFF1E2749),
          title: Text(
            isEditing ? 'Edit Category' : 'Add Category',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Category Name',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[600]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFF6B35)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text('Icon: ', style: TextStyle(color: Colors.white)),
                  GestureDetector(
                    onTap: () => _showIconPicker(context, selectedIcon, (icon) {
                      setState(() => selectedIcon = icon);
                    }),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: selectedColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: selectedColor),
                      ),
                      child: Icon(selectedIcon, color: selectedColor),
                    ),
                  ),
                  SizedBox(width: 16),
                  Text('Color: ', style: TextStyle(color: Colors.white)),
                  GestureDetector(
                    onTap: () => _showColorPicker(context, selectedColor, (color) {
                      setState(() => selectedColor = color);
                    }),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: selectedColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF6B35),
              ),
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;

                final now = DateTime.now();
                final newCategory = CategoryModel(
                  id: category?.id ?? nameController.text.toLowerCase().replaceAll(' ', '_'),
                  name: nameController.text.trim(),
                  type: type,
                  icon: selectedIcon,
                  color: selectedColor,
                  createdAt: category?.createdAt ?? now,
                  updatedAt: now,
                );

                if (isEditing) {
                  await _categoryService.updateCategory(newCategory);
                } else {
                  await _categoryService.addCategory(newCategory);
                }

                Navigator.pop(context);
              },
              child: Text(
                isEditing ? 'Update' : 'Add',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showIconPicker(BuildContext context, IconData currentIcon, Function(IconData) onIconSelected) {
    final icons = [
      Icons.restaurant, Icons.directions_car, Icons.movie, Icons.shopping_bag,
      Icons.receipt_long, Icons.local_hospital, Icons.school, Icons.flight,
      Icons.home, Icons.fitness_center, Icons.pets, Icons.games,
      Icons.work, Icons.laptop, Icons.business, Icons.trending_up,
      Icons.card_giftcard, Icons.attach_money, Icons.savings, Icons.account_balance,
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1E2749),
        title: Text('Select Icon', style: TextStyle(color: Colors.white)),
        content: Container(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: icons.length,
            itemBuilder: (context, index) {
              final icon = icons[index];
              return GestureDetector(
                onTap: () {
                  onIconSelected(icon);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: currentIcon == icon ? Color(0xFFFF6B35) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[600]!),
                  ),
                  child: Icon(
                    icon,
                    color: currentIcon == icon ? Colors.white : Colors.grey[400],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context, Color currentColor, Function(Color) onColorSelected) {
    final colors = [
      Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
      Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
      Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
      Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
      Colors.brown, Colors.grey, Colors.blueGrey, Colors.black,
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1E2749),
        title: Text('Select Color', style: TextStyle(color: Colors.white)),
        content: Container(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: colors.length,
            itemBuilder: (context, index) {
              final color = colors[index];
              return GestureDetector(
                onTap: () {
                  onColorSelected(color);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: currentColor == color ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(CategoryModel category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1E2749),
        title: Text('Delete Category', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${category.name}"? This action cannot be undone.',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _categoryService.deleteCategory(category.id);
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
