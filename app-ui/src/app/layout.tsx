import "./globals.css";

export default function RootLayout({
    children,
}: {
    children: React.ReactNode;
}) {
    return (
        <main className="sm:container mx-auto px-0 py-0 my-4 bg-slate-600 text-white font-semibold rounded">
            <div className="grid grid-cols-5">
                <div className="px-0 py-4 rounded">
                    <div className="box-content pb-4 border-b-2 text-center text-xl">
                        Time Tracker
                    </div>
                </div>
                <div className="col-span-4 rounded-r bg-slate-500 min-h-screen px-4 py-4">
                    {children}
                </div>
            </div>
        </main>
    );
}
