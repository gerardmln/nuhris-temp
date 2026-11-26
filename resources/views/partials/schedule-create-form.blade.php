<div class="rounded-2xl border border-slate-300 bg-white p-5 shadow-sm">
    @if (session('error'))
        <div class="mb-4 rounded-lg border border-red-300 bg-red-50 px-4 py-3 text-sm text-red-800">{{ session('error') }}</div>
    @endif

    @if ($errors->any())
        <div class="mb-4 rounded-lg border border-red-300 bg-red-50 px-4 py-3 text-sm text-red-800">
            <p class="font-semibold">Could not save the schedule. Please fix the following:</p>
            <ul class="mt-2 list-disc pl-5">
                @foreach ($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    <form method="POST" action="{{ $storeRoute }}" class="space-y-6">
        @csrf

        <div class="grid gap-4 md:grid-cols-2">
            <div>
                <label class="block text-sm font-semibold text-slate-700">Employee</label>
                <select
                    name="employee_id"
                    id="schedule-employee"
                    required
                    data-create-route-template="{{ $createRouteTemplate }}"
                    class="mt-1 w-full rounded-md border border-slate-300 px-3 py-2 text-sm"
                >
                    <option value="">Select employee</option>
                    @foreach ($employees as $employee)
                        <option value="{{ $employee->id }}" @selected($selectedEmployee?->id === $employee->id)>
                            {{ $employee->full_name }} — {{ $employee->employee_id }}
                        </option>
                    @endforeach
                </select>
            </div>
            <div>
                <label class="block text-sm font-semibold text-slate-700">Term</label>
                <select name="term_label" required class="mt-1 w-full rounded-md border border-slate-300 px-3 py-2 text-sm">
                    <option value="">Select term</option>
                    @foreach ($termLabels as $termLabel)
                        <option value="{{ $termLabel }}" @selected(old('term_label') === $termLabel)>{{ $termLabel }}</option>
                    @endforeach
                </select>
            </div>
        </div>

        @if ($selectedEmployee?->isContractualFaculty())
            <div>
                <label for="term_start_date" class="block text-sm font-semibold text-slate-700">Term start date</label>
                <input
                    id="term_start_date"
                    type="date"
                    name="term_start_date"
                    value="{{ old('term_start_date') }}"
                    required
                    class="mt-1 w-full rounded-md border border-slate-300 px-3 py-2 text-sm md:w-64"
                >
                <p class="mt-1 text-xs text-slate-500">Used to start this contractual faculty employee's 3 VL / 3 SL / 3 EL term balance.</p>
            </div>
        @endif

        <div class="grid grid-cols-1 gap-4 lg:grid-cols-2">
            @foreach ($weekDays as $day)
                @php
                    $dayMode = old("days.{$day['key']}.mode", 'no_work');
                @endphp
                <div class="rounded-xl border border-slate-300 bg-slate-50 p-4" data-day-card>
                    <div class="flex items-center justify-between gap-3">
                        <h3 class="font-semibold text-slate-900">{{ $day['label'] }}</h3>
                        <div class="flex rounded-full border border-slate-200 bg-white p-1 text-xs font-semibold">
                            <label class="cursor-pointer rounded-full px-3 py-1 transition-colors" data-work-label>
                                <input type="radio" name="days[{{ $day['key'] }}][mode]" value="with_work" @checked($dayMode === 'with_work') data-has-work class="sr-only">
                                With Work
                            </label>
                            <label class="cursor-pointer rounded-full px-3 py-1 transition-colors" data-no-work-label>
                                <input type="radio" name="days[{{ $day['key'] }}][mode]" value="no_work" @checked($dayMode === 'no_work') data-no-work class="sr-only">
                                No Work
                            </label>
                        </div>
                    </div>

                    <div class="mt-3 grid grid-cols-2 gap-3" data-day-times style="{{ $dayMode === 'with_work' ? '' : 'display:none;' }}">
                        <div>
                            <label class="block text-xs font-semibold uppercase text-slate-600">Time In</label>
                            <input type="time" name="days[{{ $day['key'] }}][time_in]" value="{{ old("days.{$day['key']}.time_in") }}" class="mt-1 w-full rounded-md border border-slate-300 px-3 py-2 text-sm">
                        </div>
                        <div>
                            <label class="block text-xs font-semibold uppercase text-slate-600">Time Out</label>
                            <input type="time" name="days[{{ $day['key'] }}][time_out]" value="{{ old("days.{$day['key']}.time_out") }}" class="mt-1 w-full rounded-md border border-slate-300 px-3 py-2 text-sm">
                        </div>
                    </div>
                </div>
            @endforeach
        </div>

        <div class="flex items-center justify-between rounded-xl border border-slate-300 bg-slate-50 p-4">
            <p class="text-sm text-slate-600">The schedule will be saved as approved and the employee will be notified.</p>
            <button type="submit" class="rounded-md bg-[#00386f] px-5 py-2 text-sm font-semibold text-white shadow-sm hover:bg-[#002f5d]">
                Add & Approve Schedule
            </button>
        </div>
    </form>
</div>

<script @cspNonce>
    document.querySelectorAll('[data-day-card]').forEach((card) => {
        const work = card.querySelector('[data-has-work]');
        const noWork = card.querySelector('[data-no-work]');
        const times = card.querySelector('[data-day-times]');
        const workLabel = card.querySelector('[data-work-label]');
        const noWorkLabel = card.querySelector('[data-no-work-label]');

        const update = () => {
            times.style.display = work.checked ? '' : 'none';

            workLabel.className = work.checked
                ? 'cursor-pointer rounded-full bg-emerald-600 px-3 py-1 text-white shadow-sm transition-colors'
                : 'cursor-pointer rounded-full px-3 py-1 text-emerald-700 transition-colors';

            noWorkLabel.className = noWork.checked
                ? 'cursor-pointer rounded-full bg-red-600 px-3 py-1 text-white shadow-sm transition-colors'
                : 'cursor-pointer rounded-full px-3 py-1 text-red-700 transition-colors';
        };

        work.addEventListener('change', update);
        noWork.addEventListener('change', update);
        update();
    });

    const employeeSelect = document.querySelector('#schedule-employee');
    employeeSelect?.addEventListener('change', () => {
        if (!employeeSelect.value) return;
        const template = employeeSelect.dataset.createRouteTemplate;
        window.location.href = template.replace('__EMPLOYEE__', employeeSelect.value);
    });
</script>
