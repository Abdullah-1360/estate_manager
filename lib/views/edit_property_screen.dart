import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../core/constants.dart';
import '../models/property_model.dart';
import '../viewmodels/property_viewmodel.dart';
import '../widgets/custom_text_field.dart';

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
  late TextEditingController _imageUrlController;
  late TextEditingController _bedroomsController;
  late TextEditingController _bathroomsController;
  PropertyStatus _status = PropertyStatus.active;

  bool get _isEditing => widget.property != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.property?.title ?? '');
    _addressController = TextEditingController(text: widget.property?.address ?? '');
    _priceController = TextEditingController(text: widget.property?.price.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.property?.description ?? '');
    _imageUrlController = TextEditingController(text: widget.property?.imageUrl ?? '');
    _bedroomsController = TextEditingController(text: widget.property?.bedrooms.toString() ?? '');
    _bathroomsController = TextEditingController(text: widget.property?.bathrooms.toString() ?? '');
    _status = widget.property?.status ?? PropertyStatus.active;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    super.dispose();
  }

  void _saveProperty() {
    if (_formKey.currentState!.validate()) {
      final viewModel = Provider.of<PropertyViewModel>(context, listen: false);

      final property = PropertyModel(
        id: _isEditing ? widget.property!.id : const Uuid().v4(),
        title: _titleController.text,
        address: _addressController.text,
        price: double.parse(_priceController.text),
        description: _descriptionController.text,
        imageUrl: _imageUrlController.text.isNotEmpty
            ? _imageUrlController.text
            : 'https://via.placeholder.com/400', // Default placeholder
        bedrooms: int.parse(_bedroomsController.text),
        bathrooms: int.parse(_bathroomsController.text),
        status: _status,
      );

      if (_isEditing) {
        viewModel.updateProperty(property);
      } else {
        viewModel.addProperty(property);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Property' : 'Add New Property'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Basic Information'),
                    _buildCard(
                      children: [
                        CustomTextField(
                          controller: _titleController,
                          label: 'Property Title',
                          hint: 'e.g., Luxury Villa in Malibu',
                          validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _addressController,
                          label: 'Address',
                          hint: 'e.g., 123 Beach Rd',
                          validator: (value) => value!.isEmpty ? 'Please enter an address' : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Details & Pricing'),
                    _buildCard(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _priceController,
                                label: 'Price',
                                hint: '0.00',
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Required';
                                  if (double.tryParse(value) == null) return 'Invalid number';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<PropertyStatus>(
                                value: _status,
                                decoration: InputDecoration(
                                  labelText: 'Status',
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                items: PropertyStatus.values.map((status) {
                                  return DropdownMenuItem(
                                    value: status,
                                    child: Text(status.toString().split('.').last.toUpperCase()),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _status = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _bedroomsController,
                                label: 'Bedrooms',
                                hint: 'e.g. 3',
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Required';
                                  if (int.tryParse(value) == null) return 'Invalid';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomTextField(
                                controller: _bathroomsController,
                                label: 'Bathrooms',
                                hint: 'e.g. 2',
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Required';
                                  if (int.tryParse(value) == null) return 'Invalid';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _descriptionController,
                          label: 'Description',
                          hint: 'Describe the property...',
                          maxLines: 4,
                          validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Media'),
                    _buildCard(
                      children: [
                        CustomTextField(
                          controller: _imageUrlController,
                          label: 'Image URL',
                          hint: 'https://example.com/image.jpg',
                        ),
                        const SizedBox(height: 16),
                        if (_imageUrlController.text.isNotEmpty)
                          Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey[100],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.network(
                              _imageUrlController.text,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 100), // Space for bottom button
                  ],
                ),
              ),
            ),
          ),
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
                onPressed: _saveProperty,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _isEditing ? 'Update Listing' : 'Create Listing',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
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
      child: Column(children: children),
    );
  }
}
