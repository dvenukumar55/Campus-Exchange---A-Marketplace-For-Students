import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../providers/listing_provider.dart';
import '../services/listing_service.dart';
import '../widgets/custom_text_field.dart';

class SelectedImage {
  final XFile xFile;
  final Uint8List bytes;
  final String name;
  final String mimeType;
  final int size;

  SelectedImage({
    required this.xFile,
    required this.bytes,
    required this.name,
    required this.mimeType,
    required this.size,
  });
}

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

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

  final List<SelectedImage> _selectedImages = [];
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

  void _showImageSourcePicker() {
    if (_isSubmitting || _isUploadingImage) return;

    final remainingSlots = 5 - _selectedImages.length;
    if (remainingSlots <= 0) {
      _showMessage(
        'You can add a maximum of 5 photos.',
        isError: true,
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111936),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        side: BorderSide(color: Color(0x1FFFFFFF)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Item Photo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Choose photo source (supports JPG, PNG, WEBP, GIF, BMP, HEIC, TIFF)',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _buildPickerOption(
                        icon: Icons.photo_library_rounded,
                        label: 'Gallery',
                        onTap: () {
                          Navigator.pop(ctx);
                          _pickImagesFromGallery();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPickerOption(
                        icon: Icons.camera_alt_rounded,
                        label: 'Camera',
                        onTap: () {
                          Navigator.pop(ctx);
                          _pickImageFromCamera();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1228),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: const Color(0xFF60A5FA),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImagesFromGallery() async {
    try {
      final List<XFile> pickedImages = await _imagePicker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1800,
      );

      if (pickedImages.isEmpty) return;

      final remainingSlots = 5 - _selectedImages.length;
      if (remainingSlots <= 0) return;

      final imagesToAdd = pickedImages.take(remainingSlots).toList();
      await _processAndAddImages(imagesToAdd);

      if (pickedImages.length > remainingSlots) {
        _showMessage(
          'Maximum 5 photos allowed. First 5 were added.',
          isError: false,
        );
      }
    } catch (e) {
      _showMessage(
        'Unable to pick photos: $e',
        isError: true,
      );
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1800,
      );

      if (photo == null) return;
      await _processAndAddImages([photo]);
    } catch (e) {
      _showMessage(
        'Unable to access camera: $e',
        isError: true,
      );
    }
  }

  Future<void> _processAndAddImages(List<XFile> files) async {
    final List<SelectedImage> processed = [];

    for (final file in files) {
      try {
        final bytes = await file.readAsBytes();
        if (bytes.isEmpty) continue;

        final filename = file.name.isNotEmpty
            ? file.name
            : 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final mimeType = file.mimeType ?? _guessMimeType(filename);

        processed.add(
          SelectedImage(
            xFile: file,
            bytes: bytes,
            name: filename,
            mimeType: mimeType,
            size: bytes.length,
          ),
        );
      } catch (e) {
        debugPrint('Error reading image bytes: $e');
      }
    }

    if (processed.isNotEmpty && mounted) {
      setState(() {
        _selectedImages.addAll(processed);
      });
    }
  }

  String _guessMimeType(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'bmp':
        return 'image/bmp';
      case 'heic':
        return 'image/heic';
      case 'heif':
        return 'image/heif';
      case 'tiff':
      case 'tif':
        return 'image/tiff';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  void _removeImage(int index) {
    if (_isSubmitting || _isUploadingImage) return;

    setState(() {
      _selectedImages.removeAt(index);

      if (index < _photoRefs.length) {
        _photoRefs.removeAt(index);
      }
    });
  }

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
        final photoRef = await _listingService.uploadListingImageBytes(
          image.bytes,
          filename: image.name,
          mimeType: image.mimeType,
        );

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

  void _loadSamplePreset() {
    setState(() {
      _titleController.text = 'Scientific Calculator (FX-991EX)';
      _priceController.text = '500';
      _selectedCategory = 'Scientific Calculators';
      _selectedCondition = 'Good';
      _descriptionController.text =
          'Scientific calculator in excellent working condition. Essential for engineering mathematics and physics labs.';
    });
  }

  Future<void> _submitListing() async {
    if (!_formKey.currentState!.validate()) return;

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
      await _uploadSelectedImages();

      if (_photoRefs.isEmpty) {
        throw Exception(
          'No uploaded photo references were returned.',
        );
      }

      if (!mounted) return;

      final listingProvider =
          Provider.of<ListingProvider>(context, listen: false);

      final price = double.tryParse(_priceController.text.trim()) ?? 0.0;

      final newListing = await listingProvider.createListing(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        price: price,
        condition: _selectedCondition,
        photoRefs: List<String>.from(_photoRefs),
      );

      if (!mounted) return;

      _showMessage(
        'Listing published to campus marketplace!',
        isError: false,
      );

      Navigator.pop(context, newListing);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        e.toString().replaceAll('Exception: ', ''),
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

  void _showMessage(String text, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor:
            isError ? const Color(0xFFE11D48) : const Color(0xFF22C55E),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1128),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1128),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Create Listing',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _isSubmitting || _isUploadingImage ? null : _loadSamplePreset,
            icon: const Icon(
              Icons.auto_fix_high_rounded,
              size: 16,
              color: Color(0xFF60A5FA),
            ),
            label: const Text(
              'Sample',
              style: TextStyle(
                color: Color(0xFF60A5FA),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGuidelineBanner(),
                const SizedBox(height: 16),
                _buildStepCard(
                  stepNumber: '1',
                  stepTitle: 'Item Photos',
                  stepSubtitle:
                      'Add up to 5 photos (supports JPG, PNG, WEBP, GIF, BMP, HEIC, TIFF).',
                  child: _buildPhotoSection(),
                ),
                const SizedBox(height: 16),
                _buildStepCard(
                  stepNumber: '2',
                  stepTitle: 'Title & Category',
                  stepSubtitle: 'Define the item and select its academic domain.',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        controller: _titleController,
                        label: 'Listing Title',
                        hint: 'e.g. Drafter Set with Scale & Clips',
                        prefixIcon: Icons.title_rounded,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Listing title is required';
                          }
                          if (value.trim().length < 5) {
                            return 'Title must be at least 5 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownLabel('Category'),
                      const SizedBox(height: 8),
                      _buildCategoryDropdown(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildStepCard(
                  stepNumber: '3',
                  stepTitle: 'Pricing & Condition',
                  stepSubtitle: 'Set a fair price and honest condition assessment.',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        controller: _priceController,
                        label: 'Price in INR (₹)',
                        hint: 'e.g. 450 (0 for free giveaway)',
                        prefixIcon: Icons.currency_rupee_rounded,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Price is required';
                          }
                          final p = double.tryParse(value.trim());
                          if (p == null) {
                            return 'Enter a valid price amount';
                          }
                          if (p < 0) {
                            return 'Price cannot be negative';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownLabel('Item Condition'),
                      const SizedBox(height: 8),
                      _buildConditionDropdown(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildStepCard(
                  stepNumber: '4',
                  stepTitle: 'Description & Details',
                  stepSubtitle:
                      'Provide notes on semester use, condition, and pickup location.',
                  child: CustomTextField(
                    controller: _descriptionController,
                    label: 'Item Description',
                    hint:
                        'Mention edition, brand, working condition, or hostel room for handoff...',
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Description is required';
                      }
                      if (value.trim().length < 10) {
                        return 'Please provide at least 10 characters of description';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 24),
                _buildSubmitButton(),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
);
}

  Widget _buildGuidelineBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111936),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(
            Icons.verified_user_rounded,
            color: Color(0xFF38BDF8),
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Campus-Only Community Marketplace',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Only verified students from your campus can view and purchase this item.',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard({
    required String stepNumber,
    required String stepTitle,
    required String stepSubtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111936),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: AppTheme.buttonGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    stepNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stepTitle,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      stepSubtitle,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 114,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              ..._selectedImages.asMap().entries.map(
                (entry) {
                  final index = entry.key;
                  final image = entry.value;

                  return Container(
                    width: 114,
                    margin: const EdgeInsets.only(right: 10),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B1228),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.memory(
                          image.bytes,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: Colors.black87,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        if (index == 0)
                          Positioned(
                            left: 6,
                            bottom: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.75),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Text(
                                'COVER',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              if (_selectedImages.length < 5)
                GestureDetector(
                  onTap: _showImageSourcePicker,
                  child: Container(
                    width: 114,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B1228),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_rounded,
                          size: 28,
                          color: Color(0xFF60A5FA),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Add Photo',
                          style: TextStyle(
                            color: Color(0xFFCBD5E1),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_selectedImages.length} of 5 photos selected',
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.9,
        color: Color(0xFFCBD5E1),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B1228),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          dropdownColor: const Color(0xFF111936),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF60A5FA),
          ),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          items: AppConstants.formCategories.map((category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _selectedCategory = val;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildConditionDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B1228),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCondition,
          isExpanded: true,
          dropdownColor: const Color(0xFF111936),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF60A5FA),
          ),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          items: const [
            DropdownMenuItem(value: 'New', child: Text('New (Unused / Sealed)')),
            DropdownMenuItem(
              value: 'Like New',
              child: Text('Like New (Gently used with minimal wear)'),
            ),
            DropdownMenuItem(
              value: 'Good',
              child: Text('Good (Fully functional with normal wear)'),
            ),
            DropdownMenuItem(
              value: 'Fair',
              child: Text('Fair (Noticeable wear, fully usable)'),
            ),
          ],
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _selectedCondition = val;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final loading = _isSubmitting || _isUploadingImage;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppTheme.buttonGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppTheme.glowButtonShadow,
        ),
        child: ElevatedButton(
          onPressed: loading ? null : _submitListing,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: loading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _isUploadingImage
                          ? 'Uploading Photos...'
                          : 'Publishing Listing...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.storefront_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Publish to Campus Exchange',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
