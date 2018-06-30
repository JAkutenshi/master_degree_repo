import json
import re
import csv
import xml.etree.ElementTree as ET
import itertools

json_file_urls = []


# нету гарантии, что bm_id правильно конветнется при десериализации
# в частности из google benchmark это будет long double, а с python - int.
# Решение: оба перевести в целое, потом в строку, и оставить первые 15 символов
def id_compare(first, second) -> bool:
    first = str(int(first))[0:15]
    second = str(int(second))[0:15]
    return first == second


def read_json_from_file(url: str) -> json:
    with open(url, 'r') as input_json:
        json_obj = json.load(input_json)
    return json_obj


def write_json_to_file(filename: str, json_obj):
    with open(filename, 'w') as json_in:
        json.dump(json_obj, json_in, separators=(',', ': '), indent=4)


def process_primary(primary: ET.Element, descriptions: dict):
    json_url = primary.attrib['url']
    primary_json = read_json_from_file(json_url)

    # убираем запись, если ее имя оканчивается на _mean, _meidan или _stddev
    regexpr = re.compile(r'_mean|_median|_stddev$')
    benchmarks = [benchmark for benchmark in primary_json['benchmarks'] if not re.search(regexpr, benchmark["name"])]

    # получим названия бенчмарков и их факторов
    #benchmarks_descriptions = {}
    for benchmark in primary.findall("benchmark"):
        name = benchmark.attrib["name"]
        name.replace("/real_time", "")
        descriptions[name] = []
        for factor in benchmark.findall("factor"):
            descriptions[name].append(factor.attrib["name"])

    # перебираем все дополнительные json-ы
    for secondary in primary.findall('secondary'):
        url = secondary.attrib['url']
        key = secondary.attrib['key'] # key == "bm_id"
        secondary_json = read_json_from_file(url) # это json со значениями, которые нужно вставлять в основной

        # все дополнительные значения занести по ключу в основной json
        for benchmark in benchmarks:
            # точно ли у нас есть ключевое поле?
            if key in benchmark.keys():
                # если bm_id есть, то ищем среди вторичных значений
                for secondary_measurement in secondary_json:
                    # есть ли совпадающий id бенчмарка
                    if id_compare(benchmark[key], secondary_measurement[key]):
                        # получаем все дополнительные измерения
                        measurements = list(secondary_measurement.keys())
                        # убираем поле key
                        measurements.remove(key)
                        for measure in measurements:
                            benchmark[measure] = secondary_measurement[measure]
                        # дальше не ищем
                        break
        #######################
        # закончили со всеми вторичными файлами
    ###########################
    return benchmarks, descriptions


def process_xml(url: str):
    tree = ET.parse(url)
    root = tree.getroot()
    primaries = []
    benchmark_descriptions = {}
    for primary in root:
        benchmarks, benchmark_descriptions = process_primary(primary, benchmark_descriptions)
        for benchmark in benchmarks:
            primaries.append(benchmark)

    # записываем результат в общий full.json
    write_json_to_file("benchmarks_descriptions.json", benchmark_descriptions)
    write_json_to_file("full.json", primaries)


def process_full_json():
    with open("full.json", "r") as input_json:
        benchmarks = json.load(input_json)

    # Требуется получить набор табилц вида:
    # FX_val    1 2 3 4 5
    # [Mi]_mean 1 2 3 4 5
    # [Mi]_sd   1 2 3 4 5
    # К описанию таблицы надо:
    # FX - что за фактор и в чем измеряется
    # Mi - что за измерение и в чем измеряется
    # Fj - фиксированные значения других факторов
    # Название таблицы := BM_NAME/Fj/F_NAME/Fj - Mi
    # Если на таблице надо все измерения показать, то Mi := all

    # Для начала сгруппируем все измерения по бенчмаркам
    benchmarks_list = benchmarks # список из которого берем первый элемент и вставляем в
    measures_grouped = {}        # словарь, где для каждого бенчмарка хранится количество измерений и сами измерения
    while len(benchmarks_list) != 0:
        benchmark = benchmarks_list.pop(0)
        # уберем ненужные поля
        benchmark.pop("bm_id", None)
        benchmark.pop("time_unit", None)
        benchmark.pop("iterations", None)
        if benchmark["name"] not in measures_grouped.keys():
            # если измерений нашего бенчмарка не было, то нужно его создать, чтобы избежать ошибок инициализации
            measures_grouped[benchmark["name"]] = {
                "count": 0,
                "measures": []
            }

        measures_node = measures_grouped[benchmark["name"]]
        measures_node["count"] += 1
        # единичный узел иземерений - все что было в бенчмарке кроме имени
        measure = {}
        for key in benchmark.keys():
            if key != "name":
                measure[key] = benchmark[key]
        # добавляем узел в список
        measures_node["measures"].append(measure)
    # write_json_to_file("tmp.json", measures_grouped)

    # далее нужно обработать значения измерений, заменив список измерений списком результатов измерений
    benchmarks_processed = {}
    for benchmark in measures_grouped:
        count = measures_grouped[benchmark]["count"]        # количество измерений
        measures = measures_grouped[benchmark]["measures"]  # список словарей измерений
        # если что-то пошло не так и измерений нет
        if len(measures) == 0:
            print("SUDDENLY NO MEASURES IN BM_NAME=" + benchmark)
            return
        benchmarks_processed[benchmark] = {}
        for measure in measures:
            for measure_name in measure:
                if measure_name not in benchmarks_processed[benchmark]:
                    benchmarks_processed[benchmark][measure_name] = []
                benchmarks_processed[benchmark][measure_name].append(measure[measure_name])
    write_json_to_file("benchmark_processed.json", benchmarks_processed)

    # Коэффициент Стьюдента P=95%
    S = {
        2: 12.706,
        3: 4.303,
        4: 3.182,
        5: 2.776,
        6: 2.571,
        7: 2.447,
        8: 2.365,
        9: 2.306,
        10: 2.262,
        11: 2.228,
        12: 2.201,
        13: 2.179,
        14: 2.160,
        15: 2.145,
        16: 2.131,
        17: 2.120,
        18: 2.110,
        19: 2.101,
        20: 2.093,
        21: 2.086,
        22: 2.080,
        23: 2.074,
        24: 2.069,
        25: 2.064,
        26: 2.060,
        27: 2.056,
        28: 2.052,
        29: 2.048,
        30: 2.045
    }
    # считаем значения среднего и средней ошибки
    benchmarks_results = {}
    for benchmark_name in benchmarks_processed:
        measures = benchmarks_processed[benchmark_name]
        benchmarks_results[benchmark_name] = {}
        for measure_name in measures:
            results = measures[measure_name]
            # среднее
            mean = 0.0
            for value in results:
                mean += value
            mean = float(mean) / count
            # среднеквадратическая ошибка среднего арифметического
            deviations = []
            deviations_in_square = []
            deviations_in_square_sum = 0
            for value in results:
                deviation = mean - value
                deviations.append(deviation)
                deviation_in_square = pow(deviation, 2)
                deviations_in_square.append(deviation_in_square)
                deviations_in_square_sum += deviation_in_square
            std_mean_dev = pow(deviations_in_square_sum / (count * (count - 1)), 0.5)
            error = S[count] * std_mean_dev

            benchmarks_results[benchmark_name][measure_name] = {
                "mean": mean,
                "error": error
            }
    write_json_to_file("benchmarks_results.json", benchmarks_results)


def process_results_to_rmd():
    # Определим название бенчмарков и их факторы
    benchmarks_descriptions_from_json = read_json_from_file("benchmarks_descriptions.json")

    # Создаем словари с возможными значениями факторов. Они пойдут столбцами в таблицы как Х-значения
    benchmarks_descriptions = {}
    for benchmark_name in benchmarks_descriptions_from_json:
        for factor_name in benchmarks_descriptions_from_json[benchmark_name]:
            if benchmark_name not in benchmarks_descriptions:
                benchmarks_descriptions[benchmark_name] = {}
            benchmarks_descriptions[benchmark_name][factor_name] = []

    # получаем наши бенчмарки и из названий пытаемся сопоставить с их описанием,
    # заполняя возможные варианты
    benchmarks = read_json_from_file("benchmarks_results.json")
    benchmark_name_regexp = re.compile(r"([a-zA-Z0-9_]*\/?[a-zA-Z0-9_]*)\/.*")
    factors_string_regexp = re.compile(r"[a-zA-Z0-9_]*\/?[a-zA-Z0-9_]*(\/.*)")
    factor_match = re.compile(r"\/(\d*)")

    for benchmark in benchmarks:
        name = benchmark_name_regexp.findall(benchmark)[0]
        if name in benchmarks_descriptions:
            factors = factors_string_regexp.findall(benchmark)
            factors_list = factor_match.findall(factors[0])
            for i in range(0, len(factors_list)):
                factor_name = benchmarks_descriptions_from_json[name][i]  # имя фактора в очередности их описания
                if factors_list[i] not in benchmarks_descriptions[name][factor_name]:
                    benchmarks_descriptions[name][factor_name].append(factors_list[i])
    #print(benchmarks_descriptions)

    # далее надо составить множество таблиц путем выборки одного фактора и фиксации других
    # для этого составим регулярку для бенчмарков по конкретному фактору
    tables = []
    for benchmark_info in benchmarks_descriptions:
        factors_dict = benchmarks_descriptions[benchmark_info]
        #print(factors_dict)
        factors_order = list(benchmarks_descriptions[benchmark_info].keys())
        # в этом цикле берется один фактор, который будет Х-осью, остальные фиксируются
        for current_factor in factors_dict:
            fixed_factors = []
            # все факторы кроме выбранного должны быть перебраны
            for factor in factors_dict:
                if factor != current_factor:
                    fixed_factors.append(factors_dict[factor])
                else:
                    fixed_factors.append([-1])
            # все возможные комбинации фиксированных факторов
            combinations = list(itertools.product(*fixed_factors))
            # положение текущего фактора в имени бенчмарка
            current_factor_place = factors_order.index(current_factor)
            for combination in combinations:
                # имя таблицы
                table_name = "Benchmark name is \"" + benchmark_info + "\" by var=" + current_factor + " where"
                # шаблон для регулярки
                table_pattern = benchmark_info
                index  = 0
                for factor in combination:
                    if index != current_factor_place:
                        table_name += " " + factors_order[index] + "=" + factor
                        table_pattern += "\/" + factor
                    else:
                        table_pattern += r"\/(\d*)"
                    index += 1
                table_pattern += "$"
                #print(table_name)
                #print(table_pattern)

                # отбираем подходящие результаты тестов
                regexp = re.compile(table_pattern)
                valid_benchmarks = []
                for benchmark in benchmarks:
                    if regexp.findall(benchmark):
                        valid_benchmarks.append(benchmark)

                # создаем таблицу с результатами
                table = {}
                table["factor"] = {
                    "name": current_factor,
                    "values": factors_dict[current_factor]
                }
                for benchmark in valid_benchmarks:
                    for measure in benchmarks[benchmark]:
                        if measure not in table:
                            table[measure] = {
                                "mean": [],
                                "error": []
                            }
                        table[measure]["mean"].append(benchmarks[benchmark][measure]["mean"])
                        table[measure]["error"].append(benchmarks[benchmark][measure]["error"])

                tables.append({
                    "title": table_name,
                    "name": benchmark_info,
                    "table": table
                })
    #print(tables)
    # записываем результаты в файл
    write_json_to_file("tables.json", tables)


def list_to_rvector_var(vec_name: str, list: list) -> str:
    output = vec_name + " <- c("
    for v in list:
        output += str(v) + ", "
    output = output[0 : len(output) - 2] + ")\n"
    #output += vec_name + "\n"
    return output

def list_to_rvector(list: list) -> str:
    output = "c("
    for v in list:
        output += str(v) + ", "
    output = output[0 : len(output) - 2] + ")"
    return output

def config_rmd():
    rmd_config = ET.parse("rmd_config.xml")
    rmd_config_root = rmd_config.getroot()

    benchmarks_tables_config = {}
    for benchmark in rmd_config_root.findall("benchmark"):
        benchmark_name = benchmark.attrib["name"]
        benchmarks_tables_config[benchmark_name] = {}
        titles = benchmark.findall("titles")[0]
        titles_root = titles.findall("remap")
        benchmarks_tables_config[benchmark_name]["titles"] = {}
        for remap in titles_root:
            benchmarks_tables_config[benchmark_name]["titles"][remap.attrib["title"]] = remap.attrib["remap"]

        plots_root = benchmark.findall("plots")[0]
        plots = plots_root.findall("plot")
        benchmark_plots = benchmarks_tables_config[benchmark_name]["plots"] = []
        for plot in plots:
            measures = []
            for measure in plot.findall("measure"):
                measures.append({
                    "name": measure.attrib["name"],
                    "col": measure.attrib["col"],
                    "type": measure.attrib["type"],
                    "lty": measure.attrib["lty"]
                })
            benchmark_plots.append({
                "title": plot.attrib["title"],
                "ylab": plot.attrib["ylab"],
                "values": plot.attrib["values"],
                "bars": plot.attrib["bars"],
                "measures": measures
            })

    write_json_to_file("benchmarks_tables_config.json", benchmarks_tables_config)


def generate_rmd():
    tables = read_json_from_file("tables.json")
    benchmarks_tables_config = read_json_from_file("benchmarks_tables_config.json")

    head = '''---
title: "Пример обработки данных"
author: "Ефремов Михаил"
output:
    html_document:
        toc: true
        theme: united
---
'''
    with open("result.rmd", 'w') as out:
        out.write(head)
        for table in tables:
            # загружаем конфиг для данного бенчмарка
            table_config = benchmarks_tables_config[table["name"]]
            #print(table_config)
            vectors_list = []
            # заголовок раздела
            out.write("## " + table["title"] + "\n")
            out.write("``` {r echo=TRUE}\n" +
                      "#png(filename=\"plot.png\", width = 1600, height = 900)\n" +
                      list_to_rvector_var(table["table"]["factor"]["name"], table["table"]["factor"]["values"])
                      )
            vectors_list.append({
                "name": table["table"]["factor"]["name"],
                "title": "factor",
                "vector": table["table"]["factor"]["values"]
            })
            # вектора измерений
            for measure in table["table"]:
                if measure != "factor":
                    measure_mean_name = measure
                    measure_mean_list = table["table"][measure]["mean"]

                    out.write(list_to_rvector_var(measure_mean_name, measure_mean_list))
                    vectors_list.append({
                        "name": measure_mean_name,
                        "title": table_config["titles"][measure_mean_name],
                        "vector": measure_mean_list
                    })

            # таблица
            df = "df <- data.frame("
            for vector in vectors_list:
                df += "\"" + vector["title"] + "\"=" + vector["name"] + ", "
            df = df[0 : len(df) - 2] + ")\n"
            out.write(df)

            # графики
            for plot in table_config["plots"]:
                # рассчет высоты графика
                measures_max = []
                measures_min = []
                measures_max_err = []
                for measure in plot["measures"]:
                    measures_max.append(max(table["table"][measure["name"]]["mean"]))
                    measures_min.append(min(table["table"][measure["name"]]["mean"]))
                    measures_max_err.append(max(table["table"][measure["name"]]["error"]))

                plot_max = max(measures_max)
                plot_min = min(measures_min)
                vector_err_max = max(measures_max_err)
                height = plot_max - plot_min + 2 * vector_err_max
                border = height * 0.5
                ylim = "c(" + str(plot_min - vector_err_max - border) + ", "
                ylim += str(plot_max + vector_err_max + border) + ")"

                factor_name = table["table"]["factor"]["name"]
                r_plot = ""
                legend_titles = []
                legend_cols = []
                legend_lty = []
                legend_pch = []
                for index_measure in range(0, len(plot["measures"])):
                    measure = plot["measures"][index_measure]
                    legend_titles.append("\"" + table_config["titles"][measure["name"]] + "\"")
                    legend_cols.append("\"" + measure["col"] + "\"")
                    legend_lty.append(measure["lty"])
                    legend_pch.append("\"" + measure["type"] + "\"")

                    if index_measure == 0:
                        #чтобы график был нормальный
                        r_plot += "plot(factor(" + factor_name + ", levels=" + factor_name + "), " + measure["name"]
                        r_plot += ", type=\"" + measure["type"] + "\", col=\"" + measure["col"] + "\", lty=0, "
                        r_plot += "ylim=" + ylim + ", xlab=\"\", ylab=\"\")\n"
                        # Наносим первый график
                        r_plot += "points(factor(" + factor_name + ", levels=" + factor_name +"), " + measure["name"] + ", "
                        r_plot += "col=\"" + measure["col"] + "\", pch=\"" + measure["type"] + "\")\n"
                        r_plot += "lines(factor(" + factor_name  + ", levels=" + factor_name +"), " + measure["name"] + ", "
                        r_plot += "col=\"" + measure["col"] + "\", lty=" + measure["lty"] + ", lwd=2)\n"

                        # заголовки и подписи к осям
                        r_plot += "title(main=\"" + plot["title"] + "\", xlab=\"" + table_config["titles"][factor_name]
                        r_plot +=  "\", ylab=\"" + plot["ylab"] + "\")\n"
                    else:
                        r_plot += "points(factor(" + factor_name + ", levels=" + factor_name + "), " + measure["name"] + ", "
                        r_plot += "col=\"" + measure["col"] + "\", pch=\"" + measure["type"] + "\")\n"
                        r_plot += "lines(factor(" + factor_name + ", levels=" + factor_name + "), " + measure["name"] + ", "
                        r_plot += "col=\"" + measure["col"] + "\", lty=" + measure["lty"] + ", lwd=2)\n"

                    if plot["bars"] == "True":
                        r_plot += list_to_rvector_var("err", table["table"][measure["name"]]["error"])
                        r_plot += "avg <- " + measure["name"] + "\n"
                        r_plot += "arrows(" + factor_name + ", avg-err, " + factor_name
                        r_plot += ", avg+err, length=0.05, angle=90, code=3, col=\"" + measure["col"] + "\")\n"

                    if plot["values"] == "True":
                        r_plot += "text( factor(" + factor_name + ", levels=" + factor_name + "), "
                        r_plot += measure["name"] + ", labels=" + measure["name"] + ", cex= 0.7, pos=3)\n"
                r_plot += "legend(\"bottomright\", legend=" + list_to_rvector(legend_titles)
                r_plot += ", col=" + list_to_rvector(legend_cols) + ", lty=" + list_to_rvector(legend_lty)
                r_plot += ", pch=" + list_to_rvector(legend_pch) + ", ncol=1)\n"


                out.write(r_plot)
            out.write("```\n\n")


if __name__ == "__main__":
    process_xml("merge_config.xml")
    process_full_json()
    process_results_to_rmd()
    config_rmd()
    generate_rmd()
