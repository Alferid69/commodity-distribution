export default function Loading() {
  return (
    <div className="fixed top-0 left-0 right-0 bottom-0 bg-gray-100 bg-opacity-75 flex justify-center items-center z-50">
      <div className="animate-spin rounded-full h-32 w-32 border-t-2 border-b-2 border-blue-500"></div>
      {/* Optional text */}
      {/* <div className="text-blue-500 mt-4">Loading...</div> */}
    </div>
  );
}
