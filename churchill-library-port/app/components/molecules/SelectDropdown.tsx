import Label from "../atoms/Label";
import SelectInput, { SelectOption } from "../atoms/SelectInput";

type SelectDropdownProps = {
  label: string;
  options: SelectOption[];
  defaultOption?: SelectOption;
  className?: string;
};

const SelectDropdown = ({ options, label, defaultOption, className = "" }: SelectDropdownProps) => {
  const selectId = `${label}-filter`;
  const classes = `w-full ${className}`.trimEnd();
  return (
    <div className={classes}>
      <Label label={label} inputId={selectId} />
      <SelectInput selectId={selectId} options={options} defaultOption={defaultOption} />
    </div>
  );
};

export default SelectDropdown;
