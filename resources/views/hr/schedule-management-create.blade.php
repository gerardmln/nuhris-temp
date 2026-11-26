@extends('hr.layout')

@php
    $pageTitle = 'Add Schedule';
    $pageHeading = 'Add Employee Schedule';
@endphp

@section('content')
    <div class="mb-4 flex items-center justify-between">
        <div>
            <p class="text-xs font-semibold uppercase tracking-[0.18em] text-blue-700">Direct Schedule</p>
            <h2 class="text-3xl font-bold text-slate-900">Add Employee Schedule</h2>
        </div>
        <a href="{{ route('schedules.index') }}" class="rounded-md border border-slate-300 bg-white px-4 py-2 text-sm font-semibold text-slate-700">Back</a>
    </div>

    @include('partials.schedule-create-form', [
        'storeRoute' => route('schedules.store'),
        'createRouteTemplate' => route('schedules.create', ['employee' => '__EMPLOYEE__']),
        'selectedEmployee' => $selectedEmployee,
        'employees' => $employees,
        'weekDays' => $weekDays,
        'termLabels' => $termLabels,
    ])
@endsection
