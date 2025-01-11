import SearchIcon from "../atoms/SearchIcon";
import TextInput from "../atoms/TextInput";

type SearchFieldProps = {
  inputId: string;
  placeholder?: string;
  className?: string;
};

const SearchField = ({ inputId, placeholder = "Search by...", className = "" }: SearchFieldProps) => {
  const classes = className !== "" ? className : undefined;
  return (
    <div className={classes}>
      <SearchIcon className="inline absolute mt-4 ml-3" />
      <TextInput
        inputId={inputId}
        placeholder={placeholder}
        className="w-full pl-8"
      />
    </div>
  );
};

export default SearchField;
