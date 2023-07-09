import './globals.css'

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <>
      <header>
        Page Header
      </header>
      <main className="container">
        { children }
      </main>
    </>
  )
}
