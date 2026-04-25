-- Migration 102: Update Chapter 5 image to Neon Grotto
UPDATE chapters 
SET image_url = 'https://images.unsplash.com/photo-1558591710-4b4a1ae0f04d?auto=format&fit=crop&q=80&w=800' 
WHERE position = 5;
