export default async ({ params }) => {
  const id = (await params).id;
  return <p>Books [id === {id}] Edit page</p>
};
