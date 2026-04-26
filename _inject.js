
// ── Subscription Check ───────────────────────────────────────────────────────
async function checkSubscription() {
  try {
    const { data: sessionData } = await supabaseClient.auth.getSession();
    const token = sessionData?.session?.access_token;
    if (!token) return; // not logged in, handled elsewhere

    const backendUrl = (typeof BACKEND_URL !== 'undefined' ? BACKEND_URL : 'http://localhost:3000');
    const res = await fetch(backendUrl + '/check-subscription', {
      headers: { Authorization: 'Bearer ' + token }
    });
    if (!res.ok) return; // backend unreachable — fail open
    const { active } = await res.json();
    if (!active) {
      window.location.href = 'payment.html';
    }
  } catch (err) {
    console.warn('Subscription check failed (fail open):', err);
  }
}

// ── Barcode Scanner ──────────────────────────────────────────────────────────
var _scannerRunning = false;

function openBarcodeScanner() {
  if (!window.Quagga) { toast('Scanner not available', 'error'); return; }
  openModal('Scan Barcode', `
    <div id="scannerContainer" style="position:relative;width:100%;max-width:400px;margin:0 auto">
      <div id="interactive" class="viewport" style="width:100%;height:280px;overflow:hidden;border-radius:var(--rs);background:#000"></div>
      <div style="position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);width:80%;height:2px;background:rgba(212,175,55,.7);pointer-events:none"></div>
      <p style="text-align:center;color:var(--tx2);font-size:13px;margin-top:12px">Point camera at a product barcode</p>
    </div>`, `<button class="btn btn-outline btn-sm" onclick="stopBarcodeScanner();closeModal()">Cancel</button>`);

  setTimeout(() => {
    Quagga.init({
      inputStream: { type: 'LiveStream', target: document.querySelector('#interactive'), constraints: { facingMode: 'environment' } },
      decoder: { readers: ['ean_reader', 'ean_8_reader', 'code_128_reader', 'code_39_reader', 'upc_reader'] }
    }, err => {
      if (err) { toast('Camera access denied', 'error'); closeModal(); return; }
      Quagga.start();
      _scannerRunning = true;
    });

    Quagga.onDetected(result => {
      const code = result.codeResult.code;
      stopBarcodeScanner();
      closeModal();
      handleScannedBarcode(code);
    });
  }, 300);
}

function stopBarcodeScanner() {
  if (_scannerRunning && window.Quagga) {
    Quagga.stop();
    _scannerRunning = false;
  }
}

function handleScannedBarcode(code) {
  // Find variant by SKU matching the barcode
  const variant = DB.variants.find(v => v.sku === code);
  if (!variant) {
    toast('Product not found for barcode: ' + code, 'error');
    return;
  }
  const product = getProduct(variant.productId || variant.product_id);
  if (!product) { toast('Product data missing', 'error'); return; }

  if (currentPage === 'sales') {
    // Add to cart directly
    addToCart(variant, product);
    toast('Added: ' + product.name, 'success');
  } else {
    // Navigate to sales and add
    navigate('sales');
    setTimeout(() => { addToCart(variant, product); toast('Added: ' + product.name, 'success'); }, 400);
  }
}

