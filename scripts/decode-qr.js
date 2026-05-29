const jimpModule = require('jimp');
const jsQR = require('jsqr');

const Jimp = (jimpModule && jimpModule.default) ? jimpModule.default : jimpModule;

(async ()=>{
  try {
    const image = await Jimp.read('qr.png');
    const { data, width, height } = image.bitmap;
    // jsQR expects a Uint8ClampedArray (RGBA)
    const uint8 = new Uint8ClampedArray(data);
    const code = jsQR(uint8, width, height);
    if (code) {
      console.log('QR payload:', code.data);
      process.exit(0);
    } else {
      console.error('No QR code found');
      process.exit(2);
    }
  } catch (err) {
    console.error('Error decoding QR:', err);
    process.exit(3);
  }
})();
