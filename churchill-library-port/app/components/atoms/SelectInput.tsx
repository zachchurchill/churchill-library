export type SelectOption = {
  id: string;
  name: string;
};

type SelectInputProps = {
  selectId: string;
  options: SelectOption[];
  defaultOption?: SelectOption;
};

const SelectInput = ({ selectId, options, defaultOption }: SelectInputProps) => {
  return (
    <select
      id={selectId}
      className="w-full rounded-lg border border-solid border-slate-200"
    >
      {defaultOption !== undefined && <option value={defaultOption.id}>{defaultOption.name}</option>}
      {options.map((option, idx) => <option key={idx} value={option.id}>{option.name}</option>)}
    </select>
  );
};

export default SelectInput;
