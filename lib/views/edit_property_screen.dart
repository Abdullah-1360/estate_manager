import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../core/constants.dart';
import '../models/property_model.dart';
import '../viewmodels/property_viewmodel.dart';
import '../services/image_picker_service.dart';
import '../widgets/image_gallery_widget.dart';

class EditPropertyScreen extends StatefulWidget {
  final PropertyModel? property;

  const EditPropertyScreen({super.key, this.property});

  @override
  State<EditPropertyScreen> createState() => _EditPropertyScreenState();
}

class _EditPropertyScreenState extends State<EditPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _addressController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _bedroomsController;
  late TextEditingController _bathroomsController;
  late TextEditingController _squareFootageController;
  late TextEditingController _yearBuiltController;
  
  PropertyStatus _status = PropertyStatus.active;
  String _propertyType = 'house';
  List<File> _selectedImages = [];
  List<String> _currentImageUrls = [];
  bool _isLoading = false;

  bool get _isEditing => widget.property != null;

  final List<String> _propertyTypes = [
    'house',
    'apartment',
    'condo',
    'townhouse',
    'villa',
    'land',
    'commercial'
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.property?.title ?? '');
    _addressController = TextEditingController(text: widget.property?.address ?? '');
    _priceController = TextEditingController(text: widget.property?.price.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.property?.description ?? '');
    _bedroomsController = TextEditingController(text: widget.property?.bedrooms.toString() ?? '');
    _bathroomsController = TextEditingController(text: widget.property?.bathrooms.toString() ?? '');
    _squareFootageController = TextEditingController(text: widget.property?.squareFootage?.toString() ?? '');
    _yearBuiltController = TextEditingController(text: widget.property?.yearBuilt?.toString() ?? '');
    
    _status = widget.property?.status ?? PropertyStatus.active;
    _propertyType = widget.property?.propertyType ?? 'house';
    _currentImageUrls = widget.property?.imageUrls ?? [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _squareFootageController.dispose();
    _yearBuiltController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<File>? images = await ImagePickerService.showMultipleImagePickerDialog(context);
    if (images != null && images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  void _removeImage(int index, bool isLocal) {
    setState(() {
      if (isLocal) {
        _selectedImages.removeAt(index);
      } else {
        _currentImageUrls.removeAt(index);
      }
    });
  }


  Future<void> _saveProperty() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final viewModel = Provider.of<PropertyViewModel>(context, listen: false);

        final property = PropertyModel(
          id: _isEditing ? widget.property!.id : const Uuid().v4(),
          title: _titleController.text.trim(),
          address: _addressController.text.trim(),
          price: double.parse(_priceController.text),
          description: _descriptionController.text.trim(),
          imageUrls: _currentImageUrls, // Will be updated by backend if images are uploaded
          bedrooms: int.parse(_bedroomsController.text),
          bathrooms: int.parse(_bathroomsController.text),
          status: _status,
          squareFootage: _squareFootageController.text.isNotEmpty 
              ? double.parse(_squareFootageController.text) 
              : null,
          yearBuilt: _yearBuiltController.text.isNotEmpty 
              ? int.parse(_yearBuiltController.text) 
              : null,
          propertyType: _propertyType,
        );

        if (_isEditing) {
          await viewModel.updateProperty(property, imageFiles: _selectedImages);
        } else {
          await viewModel.addProperty(property, imageFiles: _selectedImages);
        }

        if (mounted) {
          if (viewModel.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(viewModel.error!),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_isEditing ? 'Property updated successfully' : 'Property created successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Property' : 'Add New Property'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Images Section
                    _buildSectionTitle('Property Images'),
                    _buildImagesSection(),
                    const SizedBox(height: 24),

                    // Basic Information
                    _buildSectionTitle('Basic Information'),
                    _buildCard(
                      children: [
                        _buildTextField(
                          controller: _titleController,
                          label: 'Property Title',
                          hint: 'e.g., Luxury Villa in Malibu',
                          validator: (value) => value?.isEmpty == true ? 'Please enter a title' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _addressController,
                          label: 'Address',
                          hint: 'e.g., 123 Beach Rd, Malibu, CA',
                          validator: (value) => value?.isEmpty == true ? 'Please enter an address' : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Details & Pricing
                    _buildSectionTitle('Details & Pricing'),
                    _buildCard(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _priceController,
                                label: 'Price (\$)',
                                hint: '450000',
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value?.isEmpty == true) return 'Required';
                                  if (double.tryParse(value!) == null) return 'Invalid number';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDropdown<PropertyStatus>(
                                label: 'Status',
                                value: _status,
                                items: PropertyStatus.values.map((status) {
                                  return DropdownMenuItem(
                                    value: status,
                                    child: Text(status.toString().split('.').last.toUpperCase()),
                                  );
                                }).toList(),
                                onChanged: (value) => setState(() => _status = value!),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _bedroomsController,
                                label: 'Bedrooms',
                                hint: '3',
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value?.isEmpty == true) return 'Required';
                                  if (int.tryParse(value!) == null) return 'Invalid';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: _bathroomsController,
                                label: 'Bathrooms',
                                hint: '2',
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value?.isEmpty == true) return 'Required';
                                  if (int.tryParse(value!) == null) return 'Invalid';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _squareFootageController,
                                label: 'Square Footage',
                                hint: '2500',
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value?.isNotEmpty == true && double.tryParse(value!) == null) {
                                    return 'Invalid number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: _yearBuiltController,
                                label: 'Year Built',
                                hint: '2020',
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value?.isNotEmpty == true) {
                                    final year = int.tryParse(value!);
                                    if (year == null || year < 1800 || year > DateTime.now().year + 5) {
                                      return 'Invalid year';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildDropdown<String>(
                          label: 'Property Type',
                          value: _propertyType,
                          items: _propertyTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type.toUpperCase()),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() => _propertyType = value!),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _descriptionController,
                          label: 'Description',
                          hint: 'Describe the property features and amenities...',
                          maxLines: 4,
                          validator: (value) => value?.isEmpty == true ? 'Please enter a description' : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 100), // Space for bottom button
                  ],
                ),
              ),
            ),
            // Bottom Save Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProperty,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          _isEditing ? 'Update Listing' : 'Create Listing',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesSection() {
    return _buildCard(
      children: [
        ImageGalleryWidget(
          networkImages: _currentImageUrls,
          localImages: _selectedImages,
          onRemove: _removeImage,
          onAddMore: _pickImages,
          showAddButton: true,
          showRemoveButtons: true,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: maxLines > 1,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
