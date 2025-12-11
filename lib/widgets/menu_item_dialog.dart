import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/menu_item.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';

class MenuItemDialog extends StatefulWidget {
  final MenuItem? item;

  const MenuItemDialog({super.key, this.item});

  @override
  State<MenuItemDialog> createState() => _MenuItemDialogState();
}

class _MenuItemDialogState extends State<MenuItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  String? _selectedCategoryId;

  final _firebaseService = FirebaseService();
  List<MenuCategory> _categories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nameController.text = widget.item!.name;
      _descriptionController.text = widget.item!.description;
      _priceController.text = widget.item!.price.toString();
      _imageUrlController.text = widget.item!.imageUrl;
      _selectedCategoryId = widget.item!.categoryId;
    }
    _loadCategories();
  }

  void _loadCategories() {
    _firebaseService.getCategories().listen((categories) {
      if (mounted) {
        setState(() {
          _categories = categories;
          if (_selectedCategoryId == null && categories.isNotEmpty) {
            _selectedCategoryId = categories.first.id;
          }
        });
      }
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _isLoading = true);
      try {
        final bytes = await image.readAsBytes();

        // Format filename with product name
        String namePrefix = _nameController.text.trim();
        if (namePrefix.isEmpty) {
          namePrefix = 'produto_sem_nome';
        }
        // Remove special characters and spaces
        namePrefix = namePrefix.toLowerCase().replaceAll(
          RegExp(r'[^a-z0-9]'),
          '_',
        );

        final extension = image.name.split('.').last;
        final fileName =
            '${namePrefix}_${DateTime.now().millisecondsSinceEpoch}.$extension';

        // Determine content type
        String contentType = 'image/jpeg'; // Default
        final ext = extension.toLowerCase();
        if (ext == 'png') {
          contentType = 'image/png';
        } else if (ext == 'jpg' || ext == 'jpeg') {
          contentType = 'image/jpeg';
        } else if (ext == 'webp') {
          contentType = 'image/webp';
        }

        final url = await _firebaseService.uploadImage(
          bytes,
          fileName,
          contentType,
        );

        setState(() {
          _imageUrlController.text = url;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao fazer upload da imagem: $e'),
              backgroundColor: AppTheme.danger,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final item = MenuItem(
          id: widget.item?.id ?? '',
          name: _nameController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          imageUrl: _imageUrlController.text,
          categoryId: _selectedCategoryId ?? '',
        );

        if (widget.item == null) {
          await _firebaseService.addMenuItem(item);
        } else {
          await _firebaseService.updateMenuItem(item);
        }

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Item salvo com sucesso!'),
              backgroundColor: AppTheme.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao salvar: $e'),
              backgroundColor: AppTheme.danger,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item == null ? 'Novo Item' : 'Editar Item'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Preço (R\$)'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Campo obrigatório';
                  if (double.tryParse(value!) == null) return 'Valor inválido';
                  return null;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'URL da Imagem',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.upload_file),
                    onPressed: _pickImage,
                    tooltip: 'Upload de Imagem',
                  ),
                ],
              ),
              if (_imageUrlController.text.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _imageUrlController.text,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('Erro ao carregar imagem: $error');
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, color: Colors.red),
                              SizedBox(height: 8),
                              Text(
                                'Erro ao carregar imagem',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: _categories.map((c) {
                  return DropdownMenuItem(value: c.id, child: Text(c.name));
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategoryId = value);
                },
                validator: (value) =>
                    value == null ? 'Selecione uma categoria' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _save,
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Salvar', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
