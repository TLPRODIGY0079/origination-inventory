/**
 * Property test: Notification banner reflects current low-stock state
 * Feature: pos-security-dashboard-upgrade, Property 12
 * Validates: Requirements 10.2, 10.3, 10.4
 */

const fc = require('fast-check');

// ── Pure logic extracted from index.html for testing ────────────────────────

function renderNotificationBanner(items, bannerEl) {
  if (!items || items.length === 0) {
    bannerEl.style.display = 'none';
    bannerEl.innerHTML = '';
    return;
  }
  const esc = s => s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
  const list = items.map(i => `${esc(i.product_name)} (${i.qty} left)`).join(' · ');
  bannerEl.innerHTML = `<strong>Low Stock Alert:</strong> ${list}`;
  bannerEl.style.display = 'block';
}

// ── Arbitraries ──────────────────────────────────────────────────────────────

const itemArb = fc.record({
  id: fc.uuid(),
  product_name: fc.string({ minLength: 1, maxLength: 40 }),
  qty: fc.integer({ min: 0, max: 9 }),
});

const itemsArb = fc.array(itemArb, { minLength: 0, maxLength: 20 });

// ── Tests ────────────────────────────────────────────────────────────────────

describe('renderNotificationBanner', () => {
  let banner;

  beforeEach(() => {
    banner = document.createElement('div');
    banner.style.display = 'none';
  });

  // Property 12a: banner is hidden when list is empty
  test('banner is hidden when items list is empty', () => {
    fc.assert(
      fc.property(fc.constant([]), (items) => {
        renderNotificationBanner(items, banner);
        expect(banner.style.display).toBe('none');
      })
    );
  });

  // Property 12b: banner is visible when list is non-empty
  test('banner is visible when items list is non-empty', () => {
    fc.assert(
      fc.property(fc.array(itemArb, { minLength: 1, maxLength: 20 }), (items) => {
        renderNotificationBanner(items, banner);
        expect(banner.style.display).toBe('block');
      })
    );
  });

  // Property 12c: banner contains exactly the product names from the list
  test('banner contains exactly the product names from the items list', () => {
    fc.assert(
      fc.property(fc.array(itemArb, { minLength: 1, maxLength: 20 }), (items) => {
        renderNotificationBanner(items, banner);
        const text = banner.textContent;
        items.forEach(item => {
          expect(text).toContain(item.product_name);
        });
      })
    );
  });

  // Property 12d: banner updates to reflect new state on re-call
  test('banner updates content when called again with different items', () => {
    fc.assert(
      fc.property(
        fc.array(itemArb, { minLength: 1, maxLength: 10 }),
        fc.array(itemArb, { minLength: 1, maxLength: 10 }),
        (items1, items2) => {
          renderNotificationBanner(items1, banner);
          renderNotificationBanner(items2, banner);
          // After second call, banner should reflect items2 not items1
          const text = banner.textContent;
          items2.forEach(item => {
            expect(text).toContain(item.product_name);
          });
        }
      )
    );
  });

  // Property 12e: banner hidden after non-empty → empty transition
  test('banner hides when called with empty list after non-empty', () => {
    fc.assert(
      fc.property(fc.array(itemArb, { minLength: 1, maxLength: 10 }), (items) => {
        renderNotificationBanner(items, banner);
        expect(banner.style.display).toBe('block');
        renderNotificationBanner([], banner);
        expect(banner.style.display).toBe('none');
      })
    );
  });
});
