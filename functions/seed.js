const admin = require('firebase-admin');
const path = require('path');

// To run this script, you must have the Firebase Admin SDK service account key.
// You can pass it as an argument: node seed.js ./serviceAccountKey.json
const serviceAccountPath = process.env.SERVICE_ACCOUNT_KEY || process.argv[2];

if (!serviceAccountPath && !process.env.GOOGLE_APPLICATION_CREDENTIALS) {
  console.error('ERRO: Autenticação não fornecida.');
  console.error('Você deve fornecer o caminho para a Chave de Conta de Serviço (JSON).');
  console.error('Uso: node seed.js ./caminho_para_chave.json');
  console.error('Ou setar a variável GOOGLE_APPLICATION_CREDENTIALS.');
  process.exit(1);
}

if (serviceAccountPath) {
  try {
    const serviceAccount = require(path.resolve(serviceAccountPath));
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    });
  } catch (e) {
    console.error('Erro ao carregar o arquivo JSON de credenciais:', e.message);
    process.exit(1);
  }
} else {
  admin.initializeApp();
}

const db = admin.firestore();

const categories = [
  {
    nome: 'Contratos e Acordos',
    descricao: 'Modelos de contratos, acordos de confidencialidade e prestação de serviços.',
    icone: 'description',
    icone_cor: '#4CAF50',
    criado_em: admin.firestore.FieldValue.serverTimestamp()
  },
  {
    nome: 'Manuais e Guias',
    descricao: 'Tutoriais passo a passo e documentações de uso.',
    icone: 'menu_book',
    icone_cor: '#2196F3',
    criado_em: admin.firestore.FieldValue.serverTimestamp()
  },
  {
    nome: 'Relatórios Financeiros',
    descricao: 'Demonstrativos, planilhas e análises de mercado.',
    icone: 'trending_up',
    icone_cor: '#FF9800',
    criado_em: admin.firestore.FieldValue.serverTimestamp()
  },
  {
    nome: 'Design e Marketing',
    descricao: 'Apresentações visuais, diretrizes de marca e peças publicitárias.',
    icone: 'brush',
    icone_cor: '#E91E63',
    criado_em: admin.firestore.FieldValue.serverTimestamp()
  }
];

async function seed() {
  try {
    console.log('Iniciando o seeding de Categorias Iniciais...');
    const batch = db.batch();
    
    let count = 0;
    for (const cat of categories) {
      // Create a document reference with auto-generated ID
      const ref = db.collection('categories').doc();
      batch.set(ref, cat);
      count++;
    }
    
    await batch.commit();
    console.log(`Sucesso: ${count} categorias foram criadas no Firestore!`);

    // Setting user role
    const adminUid = process.env.ADMIN_UID;
    if (adminUid) {
      console.log(`\nPromovendo o usuário [${adminUid}] a Administrador...`);
      await db.collection('users').doc(adminUid).set({
        role: 'admin'
      }, { merge: true });
      console.log(`Sucesso: Usuário [${adminUid}] agora é um Admin!`);
    } else {
      console.log('\n[NOTA] Nenhuma variável ADMIN_UID foi detectada no ambiente.');
      console.log('Se você quiser promover um usuário específico a Admin via este script, rode:');
      console.log('No Windows (PowerShell):');
      console.log('  $env:ADMIN_UID="sua_uid_aqui"; node seed.js ./caminho_para_chave.json');
      console.log('\nAlternativamente, você pode ir no Console do Firestore e criar/editar manualmente o campo "role": "admin" no documento do seu usuário na coleção "users".');
    }
    
    process.exit(0);
  } catch (error) {
    console.error('Erro ao fazer o seeding:', error);
    process.exit(1);
  }
}

seed();
