
import * as dotenv from 'dotenv';
dotenv.config();
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

console.log('DB_HOST:', process.env.DB_HOST);

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  app.enableCors({
    origin: '*',
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
    credentials: true,
  });
  
  const port = process.env.PORT || 3001;
  await app.listen(port, '0.0.0.0');
  
  console.log(`Backend API is running on: ${await app.getUrl()}`);
}

bootstrap();
