import json
from pathlib import Path


source_file = Path(
    "Homework/Homework27/grafana/dashboards/cadvisor-community.json"
)

output_file = Path(
    "Homework/Homework27/grafana/dashboards/cadvisor-macos.json"
)

dashboard = json.loads(source_file.read_text(encoding="utf-8"))

replacements = [
    (
        'name=~"$container_name",name=~".+"',
        'id=~"$container_id",id!="/"',
    ),
    (
        'name=~"$container_name"',
        'id=~"$container_id"',
    ),
    (
        'name=~".+"',
        'id!="/"',
    ),
    (
        "by (name)",
        "by (id)",
    ),
    (
        "by(name)",
        "by(id)",
    ),
]


def adapt(value):
    if isinstance(value, str):
        for old, new in replacements:
            value = value.replace(old, new)
        return value

    if isinstance(value, list):
        return [adapt(item) for item in value]

    if isinstance(value, dict):
        result = {
            key: adapt(item)
            for key, item in value.items()
        }

        if result.get("name") == "container_name":
            variable_query = (
                'label_values({__name__=~"container.*", '
                'instance=~"$docker_host", id!="/"},id)'
            )

            result["name"] = "container_id"
            result["label"] = "Container cgroup"
            result["definition"] = variable_query

            if isinstance(result.get("query"), dict):
                result["query"]["query"] = variable_query

        return result

    return value


dashboard = adapt(dashboard)

dashboard["id"] = None
dashboard["uid"] = "cadvisor-macos-adapted"
dashboard["version"] = 1
dashboard["title"] = "cAdvisor Docker Containers - macOS"

dashboard["description"] = (
    "Grafana community dashboard 21743 adapted for "
    "Docker Desktop cgroup id labels."
)

output_file.write_text(
    json.dumps(dashboard, ensure_ascii=False, indent=2),
    encoding="utf-8",
)

print(f"Created: {output_file}")