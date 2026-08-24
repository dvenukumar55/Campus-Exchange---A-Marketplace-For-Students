import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../models/listing.dart';
import '../providers/listing_provider.dart';
import '../services/listing_service.dart';
import '../widgets/custom_text_field.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({Key? key}) : super(key: key);

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();
  final ListingService _listingService = ListingService();

  String _selectedCategory = AppConstants.formCategories.first;
  String _selectedCondition = 'Good';

  // Real selected image files.
  final List<File> _selectedImages = [];

  // References returned by the backend after uploading images.
  final List<String> _photoRefs = [];

  bool _isSubmitting = false;
  bool _isUploadingImage = false;

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // PICK IMAGE FROM GALLERY
  // ------------------------------------------------------------
  Future<void> _pickImages() async {
    if (_isSubmitting || _isUploadingImage) return;

    try {
      final List<XFile> pickedImages =
          await _imagePicker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (pickedImages.isEmpty) return;

      final remainingSlots = 5 - _selectedImages.length;

      if (remainingSlots <= 0) {
        _showMessage(
          'You can add a maximum of 5 photos.',
          isError: true,
        );
        return;
      }

      final imagesToAdd = pickedImages.take(remainingSlots).toList();

      setState(() {
        for (final image in imagesToAdd) {
          final file = File(image.path);

          // Prevent the same image from being added twice.
          final alreadyAdded = _selectedImages.any(
            (existing) => existing.path == file.path,
          );

          if (!alreadyAdded) {
            _selectedImages.add(file);
          }
        }
      });

      if (pickedImages.length > remainingSlots) {
        _showMessage(
          'Only 5 photos can be added to one listing.',
          isError: true,
        );
      }
    } catch (e) {
      _showMessage(
        'Unable to open gallery: $e',
        isError: true,
      );
    }
  }

  // ------------------------------------------------------------
  // REMOVE SELECTED IMAGE
  // ------------------------------------------------------------
  void _removeImage(int index) {
    if (_isSubmitting || _isUploadingImage) return;

    setState(() {
      _selectedImages.removeAt(index);

      // If the corresponding image was already uploaded,
      // remove its reference as well.
      if (index < _photoRefs.length) {
        _photoRefs.removeAt(index);
      }
    });
  }

  // ------------------------------------------------------------
  // UPLOAD ALL SELECTED IMAGES
  // ------------------------------------------------------------
  Future<void> _uploadSelectedImages() async {
    if (_selectedImages.isEmpty) {
      throw Exception('Please add at least one item photo.');
    }

    setState(() {
      _isUploadingImage = true;
    });

    try {
      _photoRefs.clear();

      for (final image in _selectedImages) {
        final photoRef = await _listingService.uploadListingImage(image);

        if (photoRef.isEmpty) {
          throw Exception(
            'The server did not return a valid photo reference.',
          );
        }

        _photoRefs.add(photoRef);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  // ------------------------------------------------------------
  // TEST PRESET
  // ------------------------------------------------------------
  void _loadJavaBookPreset() {
    setState(() {
      _titleController.text = 'Java Programming Book';
      _priceController.text = '500';
      _selectedCategory = 'Academic / Books';
      _selectedCondition = 'Good';
      _descriptionController.text =
          'Java programming book in good condition. Covers core concepts, OOP, and data structures for 2nd/3rd year CSE.';
    });
  }

  // ------------------------------------------------------------
  // CREATE LISTING
  // ------------------------------------------------------------
  Future<void> _submitListing() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImages.isEmpty) {
      _showMessage(
        'Please add at least one item photo.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Upload real images first.
      await _uploadSelectedImages();

      if (_photoRefs.isEmpty) {
        throw Exception('No uploaded photo references were returned.');
      }

      final listingProvider =
          Provider.of<ListingProvider>(context, listen: false);

      final Listing listing = await listingProvider.createListing(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        price: double.parse(_priceController.text.trim()),
        condition: _selectedCondition,
        photoRefs: List<String>.from(_photoRefs),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${listing.title} was published successfully!',
          ),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to create listing: ${e.toString()}',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // ------------------------------------------------------------
  // MESSAGE
  // ------------------------------------------------------------
  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? AppTheme.errorColor : AppTheme.secondaryColor,
      ),
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Item Listing'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _loadJavaBookPreset,
            child: const Text(
              'Fill Preset',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------------------------------------
              // PHOTOS
              // ------------------------------------------------
              const Text(
                'Item Photos (Mandatory)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),

              const Text(
                'Add up to 5 photos from your phone gallery.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),

              const SizedBox(height: 8),

              Container(
                height: 125,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                  ),
                ),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(12),
                  children: [
                    // Selected real images
                    ..._selectedImages.asMap().entries.map(
                      (entry) {
                        final index = entry.key;
                        final image = entry.value;

                        return Container(
                          width: 90,
                          height: 100,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.primaryColor
                                  .withOpacity(0.3),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(
                                  image,
                                  fit: BoxFit.cover,
                                ),

                                // Image number
                                Positioned(
                                  left: 5,
                                  bottom: 5,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),

                                // Remove button
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // Add photo button
                    if (_selectedImages.length < 5)
                      InkWell(
                        onTap: _pickImages,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 90,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFCBD5E1),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_a_photo,
                                color: AppTheme.primaryColor,
                                size: 28,
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'Add Photo',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_selectedImages.length}/5',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ------------------------------------------------
              // TITLE
              // ------------------------------------------------
              CustomTextField(
                controller: _titleController,
                label: 'Item Title',
                hint: 'e.g. Java Programming Book, Drafter kit',
                validator: (val) {
                  if (val == null || val.trim().length < 3) {
                    return 'Title must be at least 3 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ------------------------------------------------
              // PRICE
              // ------------------------------------------------
              CustomTextField(
                controller: _priceController,
                label: 'Selling Price (₹)',
                hint: 'e.g. 500',
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Price is required';
                  }

                  final price = double.tryParse(val.trim());

                  if (price == null || price < 0) {
                    return 'Enter a valid non-negative amount';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ------------------------------------------------
              // CATEGORY
              // ------------------------------------------------
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),

              const SizedBox(height: 6),

              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(),
                items: AppConstants.formCategories.map(
                  (category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(
                        category,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  },
                ).toList(),
                onChanged: _isSubmitting
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        }
                      },
              ),

              const SizedBox(height: 16),

              // ------------------------------------------------
              // CONDITION
              // ------------------------------------------------
              const Text(
                'Condition',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),

              const SizedBox(height: 6),

              DropdownButtonFormField<String>(
                value: _selectedCondition,
                decoration: const InputDecoration(),
                items: AppConstants.formConditions.map(
                  (condition) {
                    return DropdownMenuItem(
                      value: condition,
                      child: Text(
                        condition,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  },
                ).toList(),
                onChanged: _isSubmitting
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCondition = value;
                          });
                        }
                      },
              ),

              const SizedBox(height: 16),

              // ------------------------------------------------
              // DESCRIPTION
              // ------------------------------------------------
              CustomTextField(
                controller: _descriptionController,
                label: 'Description & Item Details',
                hint:
                    'Describe condition, edition, accessories included...',
                maxLines: 4,
                validator: (val) {
                  if (val == null || val.trim().length < 5) {
                    return 'Description must be at least 5 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 28),

              // ------------------------------------------------
              // SUBMIT
              // ------------------------------------------------
              ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : _submitListing,
                child: _isSubmitting
                    ? Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _isUploadingImage
                                ? 'Uploading photos...'
                                : 'Publishing listing...',
                          ),
                        ],
                      )
                    : const Text(
                        'Post Listing to Campus Marketplace',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}