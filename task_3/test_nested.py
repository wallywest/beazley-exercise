import pytest

def flatten_dict(d, parent_key="", sep="/"):
    items = []
    for k,v in d.items():
        new_key = f"{parent_key}{sep}{k}" if parent_key else k
        if isinstance(v, dict):
            result=flatten_dict(v,new_key,sep=sep)
            items.extend(result.items())
        else:
            items.append((new_key,v))
        return dict(items)


def return_nested_object(obj, key):
    flattend = flatten_dict(obj)
    if key in flattend:
        return flattend[key]
    return None

def test_run_test_case_one():
    obj = {"a":{"b":{"c":"d"}}}
    key = "a/b/c"
    val = return_nested_object(obj, key)
    assert val == "d"

def test_run_test_case_two():
    obj = {"x":{"y":{"z":"a"}}}
    key = "x/y/z"

    val = return_nested_object(obj, key)
    assert val == "a"