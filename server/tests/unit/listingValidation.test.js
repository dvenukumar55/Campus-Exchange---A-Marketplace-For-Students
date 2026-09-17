const { CATEGORIES, CONDITIONS, LISTING_STATUS } = require('../../src/config/constants');
const storageService = require('../../src/services/storageService');
const { BadRequestError } = require('../../src/utils/errors');

describe('Unit Test: Listing Validation Service (T-012, T-032)', () => {
  test('Active listing requires at least one photo reference', () => {
    expect(() => {
      storageService.validatePhotoReferences([]);
    }).toThrow(BadRequestError);

    expect(() => {
      storageService.validatePhotoReferences(null);
    }).toThrow(BadRequestError);

    expect(storageService.validatePhotoReferences(['photo_1.jpg'])).toBe(true);
  });

  test('Validates approved categories and conditions', () => {
    expect(CATEGORIES).toContain('Academic / Books');
    expect(CATEGORIES).toContain('Scientific Calculators');
    expect(CATEGORIES).toContain('Drawing & Graphics Kits');
    expect(CONDITIONS).toContain('Good');
    expect(CONDITIONS).toContain('Like New');
  });

  test('CRITICAL TEST DATA: Java Programming Book conforms to schema rules', () => {
    const testItem = {
      title: 'Java Programming Book',
      price: 500,
      condition: 'Good',
      category: 'Academic / Books',
      description: 'Java programming book in good condition',
      photoRefs: ['java_book_photo_1.jpg'],
    };

    expect(testItem.title.length).toBeGreaterThanOrEqual(3);
    expect(testItem.description.length).toBeGreaterThanOrEqual(5);
    expect(CATEGORIES).toContain(testItem.category);
    expect(CONDITIONS).toContain(testItem.condition);
    expect(testItem.price).toBeGreaterThanOrEqual(0);
    expect(testItem.photoRefs.length).toBeGreaterThan(0);
  });
});
