// pages/_app.tsx
import React from 'react';
import { ThemeProvider } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import { CacheProvider } from '@emotion/react';
import createCache from '@emotion/cache';
import { Theme } from '@mui/material/styles';
import { ThemeOptions } from '@mui/material/styles';
import { createTheme } from '@mui/material/styles';

// Emotion cache
const cache = createCache({ key: 'css', prepend: true });

// Custom theme
const themeOptions: ThemeOptions = {
  // define your theme options here
};

const theme: Theme = createTheme(themeOptions);

// Custom App component
const MyApp: React.FC<{ Component: React.ComponentType; pageProps: any }> = ({
  Component,
  pageProps,
}) => {
  return (
    <CacheProvider value={cache}>
      <ThemeProvider theme={theme}>
        <CssBaseline />
        <Component {...pageProps} />
      </ThemeProvider>
    </CacheProvider>
  );
};

export default MyApp;
