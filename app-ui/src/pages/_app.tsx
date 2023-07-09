import React from 'react';
import RootLayout from '@/app/layout';

// Custom App component
const MyApp: React.FC<{ Component: React.ComponentType; pageProps: any }> = ({
  Component,
  pageProps,
}) => {
  return (
    <RootLayout>
      <Component {...pageProps} />
    </RootLayout>
  );
};

export default MyApp;
