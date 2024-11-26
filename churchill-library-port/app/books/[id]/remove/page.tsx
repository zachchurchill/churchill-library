export default async ({ params }) => {
  const id = (await params).id;
  return <p>Books [id === {id}] Remove page</p>
};
