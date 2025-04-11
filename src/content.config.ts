import { glob } from 'astro/loaders';
import { defineCollection, z } from 'astro:content';

const wiki = defineCollection({
    loader: glob({ base: './src/wiki', pattern: '**/*.{md,mdx}' }),
    schema: z.object({
        title: z.string()
    }),
});

export const collections = { wiki };