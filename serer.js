const fastify = require('fastify')({ 
  logger: false // CRÍTICO: Logs desactivados para ahorrar CPU/IO
});
const Redis = require('ioredis');

// Conexión a Dragonfly (mismo protocolo que Redis)
const redis = new Redis({
  host: '127.0.0.1', 
  port: 6379,
  maxRetriesPerRequest: 1, // Fallar rápido si DB está caída
  connectTimeout: 2000
});

// 1. Endpoint: Semilla (Crear datos de prueba)
// Simula cargar productos en caché
fastify.get('/seed', async (request, reply) => {
  const pipeline = redis.pipeline();
  for (let i = 0; i < 100; i++) {
    // Arquitectura Óptima: Hash para objetos
    pipeline.hset(`product:${i}`, {
      id: i,
      name: `Producto de Prueba ${i}`,
      price: (Math.random() * 100).toFixed(2),
      stock: 500
    });
  }
  await pipeline.exec();
  return { status: 'Datos cargados' };
});

// 2. Endpoint: Leer Producto (Simula carga de página de producto)
// Lectura ligera
fastify.get('/product/:id', async (request, reply) => {
  const { id } = request.params;
  const product = await redis.hgetall(`product:${id}`);
  
  if (!product || Object.keys(product).length === 0) {
    reply.code(404);
    return { error: 'Not found' };
  }
  return product;
});

// 3. Endpoint: Añadir al Carrito (Simula escritura/transacción)
// Escritura + Lógica simple
fastify.post('/cart/:userId', async (request, reply) => {
  const { userId } = request.params;
  const { productId, qty } = request.body || { productId: 1, qty: 1 };

  // Usamos HINCRBY para ser atómicos y eficientes
  const newQty = await redis.hincrby(`cart:${userId}`, productId, qty);
  
  // TTL de 1 hora para no llenar la RAM con basura vieja
  await redis.expire(`cart:${userId}`, 3600); 

  return { userId, productId, cartQty: newQty };
});

// Healthcheck
fastify.get('/', async () => ({ status: 'ok', engine: 'dragonfly' }));

const start = async () => {
  try {
    await fastify.listen({ port: 3000, host: '0.0.0.0' });
    console.log('Servidor corriendo en puerto 3000');
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
};
start();