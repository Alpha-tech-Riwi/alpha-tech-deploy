const axios = require('axios');

async function testEcosystem() {
  console.log('🧪 Alpha Tech Ecosystem Integration Test\n');
  
  const tests = [
    {
      name: 'Backend API',
      url: 'http://localhost:3000',
      test: async () => {
        const response = await axios.get('http://localhost:3000');
        return response.data === 'Hello World!';
      }
    },
    {
      name: 'QR Service',
      url: 'http://localhost:3004/health',
      test: async () => {
        const response = await axios.get('http://localhost:3004/health');
        return response.data.status === 'OK';
      }
    },
    {
      name: 'Notification Service',
      url: 'http://localhost:3003/notifications/owner/test',
      test: async () => {
        const response = await axios.get('http://localhost:3003/notifications/owner/0581b193-636f-4df5-828d-d1426fa2b014');
        return Array.isArray(response.data);
      }
    },
    {
      name: 'Location Service',
      url: 'http://localhost:3002/location',
      test: async () => {
        const response = await axios.post('http://localhost:3002/location', {
          collarId: 'TEST123',
          latitude: 6.25,
          longitude: -75.59
        });
        return response.status === 201;
      }
    }
  ];

  let passed = 0;
  let total = tests.length;

  for (const test of tests) {
    try {
      console.log(`Testing ${test.name}...`);
      const result = await test.test();
      if (result) {
        console.log(`✅ ${test.name} - PASSED`);
        passed++;
      } else {
        console.log(`❌ ${test.name} - FAILED`);
      }
    } catch (error) {
      console.log(`❌ ${test.name} - ERROR: ${error.message}`);
    }
  }

  console.log(`\n📊 Results: ${passed}/${total} services working`);
  
  if (passed === total) {
    console.log('🎉 All services are operational!');
  } else {
    console.log('⚠️  Some services need attention');
  }

  // Test QR Flow
  console.log('\n🔍 Testing QR Flow...');
  try {
    const qrResponse = await axios.get('http://localhost:3004/found/PETOBZN9T1I');
    if (qrResponse.data.includes('Mascota Encontrada')) {
      console.log('✅ QR Flow - WORKING');
    } else {
      console.log('❌ QR Flow - FAILED');
    }
  } catch (error) {
    console.log(`❌ QR Flow - ERROR: ${error.message}`);
  }
}

testEcosystem().catch(console.error);